#!/bin/sh
# Load MeseCraft headless on a throwaway world and report problems:
# Lua errors, engine warnings (deprecations, missing biomes, ...) and
# craft recipes that use items which don't exist.
#
# Usage: utils/check.sh            (uses `luanti` from PATH)
#        LUANTI=/path/to/luanti utils/check.sh   (or a server-only luantiserver)
# Exits non-zero if anything was found.

set -u
LUANTI=${LUANTI:-luanti}
GAME_DIR=$(cd "$(dirname "$0")/.." && pwd)
GAME_ID=$(basename "$GAME_DIR")
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

WORLD="$TMP/world"
mkdir -p "$WORLD/worldmods/mesecraft_check"
printf 'gameid = %s\nbackend = sqlite3\nplayer_backend = sqlite3\nauth_backend = sqlite3\nmod_storage_backend = sqlite3\n' "$GAME_ID" > "$WORLD/world.mt"
printf 'name = mesecraft_check\n' > "$WORLD/worldmods/mesecraft_check/mod.conf"
cat > "$WORLD/worldmods/mesecraft_check/init.lua" <<'EOF'
minetest.register_on_mods_loaded(function()
	for output in pairs(minetest.registered_items) do
		for _, recipe in ipairs(minetest.get_all_craft_recipes(output) or {}) do
			for _, item in pairs(recipe.items or {}) do
				local name = ItemStack(item):get_name()
				if item ~= "" and not item:find("^group:")
						and not minetest.registered_items[minetest.registered_aliases[name] or name] then
					minetest.log("error", "Recipe for " .. output .. " uses unknown item " .. name)
				end
			end
		end
	end
	minetest.after(1, function() minetest.request_shutdown() end)
end)
EOF

# A server-only build (luantiserver) always runs a server and rejects --server.
case $(basename "$LUANTI") in
	*server) SERVER_FLAG= ;;
	*) SERVER_FLAG=--server ;;
esac

timeout 120 "$LUANTI" $SERVER_FLAG --gameid "$GAME_ID" --world "$WORLD" \
	--port 30199 --logfile "$TMP/log.txt" >/dev/null 2>&1

if ! grep -q "listening on" "$TMP/log.txt"; then
	echo "Server did not start:"
	grep -E "ERROR" "$TMP/log.txt" | head -40
	exit 1
fi

# Known, harmless: media files with spaces in their names.
PROBLEMS=$(grep -E "ERROR|WARNING" "$TMP/log.txt" \
	| grep -v "disallowed characters\|Maximum lag peaked" \
	| sed 's/^[0-9: -]*//' | sort | uniq -c | sort -rn)

if [ -n "$PROBLEMS" ]; then
	echo "$PROBLEMS"
	exit 1
fi
echo "OK: no errors, warnings or unknown recipe items ($("$LUANTI" --version | head -1))"
