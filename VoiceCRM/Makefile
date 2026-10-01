TOOLS := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../tools)
NAME  := $(notdir $(CURDIR))
SIM   ?= iPhone 17 Pro

.PHONY: gen build run test screenshot clean
gen:        ; xcodegen generate
build:      ; $(TOOLS)/build.sh $(NAME) "$(SIM)"
run:        ; $(TOOLS)/run.sh $(NAME) "$(SIM)"
test:       ; $(TOOLS)/test.sh $(NAME) "$(SIM)"
screenshot: ; $(TOOLS)/screenshot.sh
clean:      ; rm -rf build DerivedData
