SCRIPT= genretro.sh
MAN= genretro.1

BINDIR?= bin
DESTDIR?= /usr/local/

install:
	${INSTALL} ${INSTALL_COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE} \
		${.CURDIR}/${SCRIPT} ${DESTDIR}${BINDIR}/genretro

.include <bsd.prog.mk>
