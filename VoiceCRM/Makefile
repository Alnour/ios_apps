TOOLS := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../tools)
NAME  := $(notdir $(CURDIR))
SIM   ?= iPhone 17 Pro
METHOD ?= development
PART   ?= build

.PHONY: gen build run run-device build-device archive upload bump doctor test screenshot clean
gen:        ; xcodegen generate
build:      ; $(TOOLS)/build.sh $(NAME) "$(SIM)"
run:        ; $(TOOLS)/run.sh $(NAME) "$(SIM)"
test:       ; $(TOOLS)/test.sh $(NAME) "$(SIM)"
screenshot: ; $(TOOLS)/screenshot.sh
clean:      ; rm -rf build DerivedData
run-device: ; $(TOOLS)/run-device.sh $(NAME) "$(DEVICE)"
build-device: ; $(TOOLS)/build-device.sh $(NAME)
archive:    ; $(TOOLS)/archive.sh $(NAME) $(METHOD)
upload:     ; $(TOOLS)/upload.sh $(NAME)
bump:       ; $(TOOLS)/bump-version.sh $(NAME) $(PART)
doctor:     ; $(TOOLS)/signing-doctor.sh $(NAME)
