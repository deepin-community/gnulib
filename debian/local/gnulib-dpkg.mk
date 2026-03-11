# gnulib-dpkg.mk: useful debian/rules definitions for gnulib packages

# Copyright (C) 2024 Simon Josefsson <simon@josefsson.org>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


# =====
# HOWTO
# =====
#
# A package that rely on gnulib's ./bootstrap infrastructure would
# want to have something like the following in debian/rules.
#
# include /usr/share/gnulib/debian/gnulib-dpkg.mk
# %:
#	dh $@ --without autoreconf
# pull:
# 	./bootstrap --gnulib-srcdir=$(GNULIB_DEB_DEBIAN_GNULIB) --pull
# gen:
# 	./bootstrap --gnulib-srcdir=$(GNULIB_DEB_DEBIAN_GNULIB) --gen
# execute_before_dh_auto_configure: dh_gnulib_clone pull dh_gnulib_patch gen
#
# This makefile provides hooks for cloning ('dh_gnulib_clone') and
# patching gnulib ('dh_gnulib_patch').  Traditionally most gnulib
# package perform the cloning and running of autoreconf etc in one
# step by running ./bootstrap.  However in order to allow
# 'dh_gnulib_patch' to patch gnulib code you must separate these two
# steps, and invoke 'dh_gnulib_patch' between them.  Invoking
# 'dh_gnulib_patch' should be done as soon as the gnulib git clone has
# been prepared and the appropriate git commit checked out, and must
# be done before any files are copied out from the gnulib directory
# via gnulib-tool, autoreconf etc.  Fortunately gnulib's ./bootstrap
# script offer a way to separate these two steps with the --gen and
# --pull flags.  For packages that use gnulib without gnulib's
# ./bootstrap script some other mechanism is needed.
#
# If you want to avoid '--without autoreconf' then we suggest to
# disable autoreconf like this instead:
#
# override_dh_autoreconf override_dh_autoreconf_clean:


_gnulib_share_path ?= /usr/share/gnulib

# Guaranteed to point to a directory with an unpackaged gnulib copy.
# The Debian package modify some paths compared to upstream, but if
# some package rely on the directory not containing such changes, the
# gnulib Debian package should probably be modified to not introduce it.
GNULIB_DEB_SRCDIR ?= $(_gnulib_share_path)

# Guaranteed to point to a git bundle provided by the Debian gnulib
# package, for as long as a git bundle is provided by the package.
GNULIB_DEB_GIT_BUNDLE ?= $(_gnulib_share_path)/gnulib.bundle

# Guaranteed to point to a URL that works with 'git clone' and where
# the content of that URL is provided by the Debian gnulib package.
# Should not require network access.  In practice this will probably
# always be a simple file path but could be changed to point to a git
# bundle or to a unpackad .git repository, or some other URL style
# accepted by 'git clone' in the future.
GNULIB_DEB_GIT_URL ?= $(GNULIB_DEB_GIT_BUNDLE)

# Where you want the git clone of gnulib to be.
GNULIB_DEB_DEBIAN_GNULIB ?= debian/gnulib

dh_gnulib_clone:
	git clone $(GNULIB_DEB_GIT_URL) $(GNULIB_DEB_DEBIAN_GNULIB)
	git -C $(GNULIB_DEB_DEBIAN_GNULIB) status
	$(GNULIB_DEB_DEBIAN_GNULIB)/gnulib-tool --version | head -1

dh_gnulib_patch:
	git -C $(GNULIB_DEB_DEBIAN_GNULIB) status
	cd $(GNULIB_DEB_DEBIAN_GNULIB) && dh_gnulib_patch
	git -C $(GNULIB_DEB_DEBIAN_GNULIB) status
	$(GNULIB_DEB_DEBIAN_GNULIB)/gnulib-tool --version | head -1
