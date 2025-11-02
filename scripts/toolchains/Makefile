# Makefile for cross-compilation toolchain
# Usage:
#   make TARGET=riscv64-unknown-elf
#   make TARGET=arm-none-eabi WITH_NEWLIB=1 JOBS=8
#   make TARGET=riscv64-unknown-elf clean
#   make TARGET=arm-none-eabi binutils gcc

# Load configuration
-include config.mk

# Target must be specified
ifndef TARGET
$(error TARGET is not set. Usage: make TARGET=riscv64-unknown-elf)
endif

# Default settings (can be overridden)
JOBS ?= $(shell nproc)
LANGUAGES ?= c,c++
WITH_NEWLIB ?= 0

# Paths
BUILD_DIR := $(TOOLCHAIN_ROOT)/builds/$(TARGET)
PREFIX := $(TOOLCHAIN_ROOT)/$(TARGET)
BINUTILS_BUILD := $(BUILD_DIR)/binutils
GCC_BUILD := $(BUILD_DIR)/gcc
NEWLIB_BUILD := $(BUILD_DIR)/newlib

# Stamps for tracking build stages
STAMPS := $(BUILD_DIR)/.stamps
BINUTILS_CONFIGURED := $(STAMPS)/binutils-configured
BINUTILS_BUILT := $(STAMPS)/binutils-built
BINUTILS_INSTALLED := $(STAMPS)/binutils-installed
GCC_CONFIGURED := $(STAMPS)/gcc-configured
GCC_BUILT := $(STAMPS)/gcc-built
GCC_INSTALLED := $(STAMPS)/gcc-installed
NEWLIB_CONFIGURED := $(STAMPS)/newlib-configured
NEWLIB_BUILT := $(STAMPS)/newlib-built
NEWLIB_INSTALLED := $(STAMPS)/newlib-installed
LIBGCC_BUILT := $(STAMPS)/libgcc-built
LIBGCC_INSTALLED := $(STAMPS)/libgcc-installed
LIBSTDCXX_BUILT := $(STAMPS)/libstdcxx-built
LIBSTDCXX_INSTALLED := $(STAMPS)/libstdcxx-installed

# Export PATH
export PATH := $(PREFIX)/bin:$(PATH)

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Logging
define log_info
	@echo -e "$(BLUE)ℹ️  $(1)$(NC)"
endef

define log_ok
	@echo -e "$(GREEN)✅ $(1)$(NC)"
endef

define log_warn
	@echo -e "$(YELLOW)⚠️  $(1)$(NC)"
endef

# Main targets
.PHONY: all clean distclean info help binutils gcc newlib libs

ifeq ($(WITH_NEWLIB),1)
all: binutils gcc newlib libs
else
all: binutils gcc libs
endif

help:
	@echo "Toolchain build system"
	@echo ""
	@echo "Usage:"
	@echo "  make TARGET=<triple> [options]"
	@echo ""
	@echo "Options:"
	@echo "  TARGET=<triple>      Target architecture (required)"
	@echo "  JOBS=<n>            Parallel jobs (default: nproc)"
	@echo "  LANGUAGES=<list>    Languages to build (default: c,c++)"
	@echo "  WITH_NEWLIB=1       Build with newlib"
	@echo ""
	@echo "Targets:"
	@echo "  all          Build complete toolchain"
	@echo "  binutils     Build binutils only"
	@echo "  gcc          Build GCC only"
	@echo "  newlib       Build newlib only"
	@echo "  libs         Build libgcc and libstdc++"
	@echo "  clean        Remove build artifacts"
	@echo "  distclean    Remove build and install directories"
	@echo "  info         Show configuration"
	@echo ""
	@echo "Examples:"
	@echo "  make TARGET=riscv64-unknown-elf"
	@echo "  make TARGET=arm-none-eabi WITH_NEWLIB=1 JOBS=8"

info:
	$(call log_info,Configuration)
	@echo "  Target:      $(TARGET)"
	@echo "  Prefix:      $(PREFIX)"
	@echo "  Build dir:   $(BUILD_DIR)"
	@echo "  Jobs:        $(JOBS)"
	@echo "  Languages:   $(LANGUAGES)"
	@echo "  With newlib: $(WITH_NEWLIB)"
	@echo ""
	@echo "Source versions:"
	@echo "  Binutils: $(BINUTILS_VERSION)"
	@echo "  GCC:      $(GCC_VERSION)"
	@echo "  Newlib:   $(NEWLIB_VERSION)"

# ============================================================================
# BINUTILS
# ============================================================================

binutils: $(BINUTILS_INSTALLED)

$(BINUTILS_CONFIGURED): | $(STAMPS)
	$(call log_info,Configuring binutils for $(TARGET))
	@mkdir -p $(BINUTILS_BUILD)
	cd $(BINUTILS_BUILD) && $(BINUTILS_SRC)/configure \
		--target=$(TARGET) \
		--prefix=$(PREFIX) \
		--with-sysroot \
		--disable-nls \
		--disable-werror \
		--disable-gdb \
		--disable-sim \
		--disable-libdecnumber \
		--disable-readline
	@touch $@

$(BINUTILS_BUILT): $(BINUTILS_CONFIGURED)
	$(call log_info,Building binutils)
	$(MAKE) -C $(BINUTILS_BUILD) -j$(JOBS)
	@touch $@

$(BINUTILS_INSTALLED): $(BINUTILS_BUILT)
	$(call log_info,Installing binutils)
	$(MAKE) -C $(BINUTILS_BUILD) install
	@touch $@
	$(call log_ok,Binutils installed)

# ============================================================================
# GCC
# ============================================================================

gcc: $(GCC_INSTALLED)

$(GCC_CONFIGURED): $(BINUTILS_INSTALLED) | $(STAMPS)
	$(call log_info,Configuring GCC for $(TARGET))
	@mkdir -p $(GCC_BUILD)
	cd $(GCC_BUILD) && $(GCC_SRC)/configure \
		--target=$(TARGET) \
		--prefix=$(PREFIX) \
		--disable-nls \
		--enable-languages=$(LANGUAGES) \
		--without-headers \
		--with-newlib \
		--disable-shared \
		--disable-threads \
		--disable-libssp \
		--disable-libgomp \
		--disable-libmudflap \
		$(if $(filter 0,$(WITH_NEWLIB)),--disable-hosted-libstdcxx,)
	@touch $@

$(GCC_BUILT): $(GCC_CONFIGURED)
	$(call log_info,Building GCC)
	$(MAKE) -C $(GCC_BUILD) -j$(JOBS) all-gcc
	@touch $@

$(GCC_INSTALLED): $(GCC_BUILT)
	$(call log_info,Installing GCC)
	$(MAKE) -C $(GCC_BUILD) install-gcc
	@touch $@
	$(call log_ok,GCC installed)

# ============================================================================
# NEWLIB
# ============================================================================

newlib: $(NEWLIB_INSTALLED)

$(NEWLIB_CONFIGURED): $(GCC_INSTALLED) | $(STAMPS)
	$(call log_info,Configuring newlib for $(TARGET))
	@mkdir -p $(NEWLIB_BUILD)
	cd $(NEWLIB_BUILD) && $(NEWLIB_SRC)/configure \
		--target=$(TARGET) \
		--prefix=$(PREFIX) \
		--disable-newlib-supplied-syscalls
	@touch $@

$(NEWLIB_BUILT): $(NEWLIB_CONFIGURED)
	$(call log_info,Building newlib)
	$(MAKE) -C $(NEWLIB_BUILD) -j$(JOBS)
	@touch $@

$(NEWLIB_INSTALLED): $(NEWLIB_BUILT)
	$(call log_info,Installing newlib)
	$(MAKE) -C $(NEWLIB_BUILD) install
	@touch $@
	$(call log_ok,Newlib installed)

# ============================================================================
# LIBRARIES
# ============================================================================

ifeq ($(WITH_NEWLIB),1)
libs: $(LIBGCC_INSTALLED) $(LIBSTDCXX_INSTALLED)
$(LIBGCC_BUILT): $(NEWLIB_INSTALLED)
else
libs: $(LIBGCC_INSTALLED) $(LIBSTDCXX_INSTALLED)
$(LIBGCC_BUILT): $(GCC_INSTALLED)
endif

$(LIBGCC_BUILT): | $(STAMPS)
	$(call log_info,Building libgcc)
	$(MAKE) -C $(GCC_BUILD) -j$(JOBS) all-target-libgcc
	@touch $@

$(LIBGCC_INSTALLED): $(LIBGCC_BUILT)
	$(call log_info,Installing libgcc)
	$(MAKE) -C $(GCC_BUILD) install-target-libgcc
	@touch $@
	$(call log_ok,libgcc installed)

$(LIBSTDCXX_BUILT): $(LIBGCC_INSTALLED) | $(STAMPS)
	$(call log_info,Building libstdc++)
	-$(MAKE) -C $(GCC_BUILD) -j$(JOBS) all-target-libstdc++-v3
	@touch $@

$(LIBSTDCXX_INSTALLED): $(LIBSTDCXX_BUILT)
	$(call log_info,Installing libstdc++)
	-$(MAKE) -C $(GCC_BUILD) install-target-libstdc++-v3
	@touch $@
	$(call log_ok,libstdc++ installed)

# ============================================================================
# UTILITIES
# ============================================================================

$(STAMPS):
	@mkdir -p $(STAMPS)

clean:
	$(call log_warn,Cleaning build directory for $(TARGET))
	rm -rf $(BUILD_DIR)

distclean: clean
	$(call log_warn,Removing installation for $(TARGET))
	rm -rf $(PREFIX)

.PHONY: verify
verify:
	@if [ -x "$(PREFIX)/bin/$(TARGET)-gcc" ]; then \
		$(call log_ok,Toolchain verified); \
		$(PREFIX)/bin/$(TARGET)-gcc --version | head -n1; \
	else \
		$(call log_warn,Toolchain not found at $(PREFIX)); \
	fi
