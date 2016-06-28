#!/usr/bin/bash

[ $# -lt 1 ] && {
	echo "Use: $0 [src_dir] <ext>";
	exit 1;
}
src=${1};
ext=${2:-mp3};

cd ${src};

for music in *.${ext} ; do
	mplayer "${music}" -nosound -ss 10:00:00 >/tmp/.${ext}.$$ 2>/dev/null;
	title=$(  cat /tmp/.${ext}.$$ | grep " Title:"  );
	artist=$( cat /tmp/.${ext}.$$ | grep " Artist:" );
	album=$(  cat /tmp/.${ext}.$$ | grep " Album:"  );

	title=${title##*:};
	artist=${artist##*:};
	album=${album##*:};

	title=${title// /};
	artist=${artist// /};
	album=${album// /};

	[ ! -z "${title}" ] && [ ! -z "${artist}" ] && {
		dir="${HOME}/${ext}/${artist:0:1}/${artist}";

		[ ! -z "${album}" ] && {
			dir="${HOME}/${ext}/${artist:0:1}/${artist}/${album}";
		}

		mkdir -p ${dir};
		mv "${music}" "${dir}/${title}.${ext}";
	}
done

cd -;

rm /tmp/.${ext}.$$;

