# common config macros (changing)
OS_VERSION = 24.04
R_VERSION=4.4.0
RS_VERSION=2024.04.1-748
ARCH_HOST := $(shell uname -m)
ARM_BUILD=arm64v8
AMD_BUILD=amd64
IMAGE_TYPE=amd
# other common macros (not changing much)
DC = docker
DB = $(DC) build
D_REP = rollinroy
DO_FLAGS =
# use cache when building
ifdef USECACHE
	CACHE_OPT =
else
  CACHE_OPT = --no-cache
endif

ifeq ($(IMAGE_TYPE),arm)
	ARCH_TYPE=$(ARM_BUILD)
	UBUNTU_REP = $(ARM_BUILD)/
	PLATFORM_OPT=--platform=linux/arm64
else
	ARCH_TYPE=$(AMD_BUILD)
	UBUNTU_REP = $(AMD_BUILD)/
	PLATFORM_OPT=--platform=linux/amd64
	IMAGE_TYPE = amd
endif

# base name macros
DB_OPTS = $(DO_FLAGS) $(CACHE_OPT)
DB_LINUX = ubuntu
DB_OS = $(DB_LINUX)-$(OS_VERSION)-hpc
DB_R = r-$(R_VERSION)
DB_BIOINF = bioinformatics-$(R_VERSION)
DB_RSTUDIO = rstudio-$(R_VERSION)

# macros of docker build file names
DF_OS = $(DB_OS).dfile
DF_R = r-latest.dfile
DF_BIOINF = bioinformatics-latest.dfile
DF_RSTUDIO = rstudio-latest.dfile

# macros of docker image tags
IMAGE_DATE = $(shell date +'%m-%d-%y')
DT_OS = $(IMAGE_DATE)
DT_R = $(IMAGE_DATE)
DT_BIOINF = $(IMAGE_DATE)
DT_RSTUDIO = $(IMAGE_DATE)

# macros of docker image names
DI_OS = $(DB_OS)-$(IMAGE_TYPE)
DI_R = $(DB_R)-$(IMAGE_TYPE)
DI_BIOINF = $(DB_BIOINF)-$(IMAGE_TYPE)
DI_RSTUDIO = $(DB_RSTUDIO)-$(IMAGE_TYPE)

D_IMAGES = $(DI_OS) $(DI_R) $(DI_BIOINF) $(DI_RSTUDIO)
D_ALL_IMAGES = $(addsuffix .image,$(D_IMAGES))
D_PUSH = $(addsuffix .push,$(D_IMAGES))
# summary

# do stuff
.PHONY:  all

all: $(D_ALL_IMAGES)
	@echo ">>> Build is complete"
	@echo ">>> UBUNTU_REP: $(UBUNTU_REP)"
	@echo ">>> PLATFORM_OPT of build: $(PLATFORM_OPT)"

push: $(D_PUSH)
	@echo ">>> Push is complete"

$(DI_OS).image: $(DF_OS)
	@echo ">>> $(shell date)" Building $(D_REP)$(DI_OS):$(DT_OS)
	$(DB) -t $(D_REP)$(DI_OS):$(DT_OS) $(DB_OPTS) $(PLATFORM_OPT) \
        --progress plain \
        --build-arg base_os=$(DB_LINUX) \
        --build-arg ubuntu_rep=$(UBUNTU_REP) \
        --build-arg arch_type=$(ARCH_TYPE) \
        --build-arg itag=$(OS_VERSION) \
        -f $(DF_OS) . 2>&1 | tee build_$(DI_OS).log
	$(DC) tag $(D_REP)$(DI_OS):$(DT_OS) $(D_REP)$(DI_OS):latest
	touch $(DI_OS).image

$(DI_R).image: $(DF_R) $(DI_OS).image
	@echo ">>> $(shell date)" Building $(D_REP)$(DI_R):$(DT_R)
	export DOCKER_BUILDKIT=0
	$(DB) -t $(D_REP)$(DI_R):$(DT_R) $(DB_OPTS) $(PLATFORM_OPT) \
        --progress plain \
        --build-arg ra_version=$(R_VERSION) \
        --build-arg arch_type=$(ARCH_TYPE) \
        --build-arg base_name=$(D_REP)$(DI_OS) \
        --build-arg itag=latest \
        -f $(DF_R) . 2>&1 | tee  build_$(DI_R).log
	$(DC) tag $(D_REP)$(DI_R):$(DT_R) $(D_REP)$(DI_R):latest
	touch $(DI_R).image

$(DI_BIOINF).image: $(DF_BIOINF) $(DI_R).image
	@echo ">>> $(shell date)" Building $(D_REP)$(DI_BIOINF):$(DT_BIOINF)
	$(DB) -t $(D_REP)$(DI_BIOINF):$(DT_BIOINF) $(DB_OPTS) $(PLATFORM_OPT) \
        --progress plain \
        --build-arg base_name=$(D_REP)$(DI_R) \
        --build-arg rs_version=$(RS_VERSION) \
        --build-arg arch_type=$(ARCH_TYPE) \
        --build-arg itag=latest \
        -f $(DF_BIOINF) . 2>&1 | tee build_$(DI_BIOINF).log
	$(DC) tag $(D_REP)$(DI_BIOINF):$(DT_BIOINF) $(D_REP)$(DI_BIOINF):latest
	touch $(DI_BIOINF).image

$(DI_RSTUDIO).image: $(DF_RSTUDIO) $(DI_R).image
	@echo ">>> $(shell date)" Building $(D_REP)$(DI_RSTUDIO):$(DT_RSTUDIO)
	$(DB) -t $(D_REP)$(DI_RSTUDIO):$(DT_RSTUDIO) $(DB_OPTS) $(PLATFORM_OPT) \
        --progress plain \
        --build-arg rs_version=$(RS_VERSION) \
        --build-arg base_name=$(D_REP)$(DI_R) \
        --build-arg image_type=$(IMAGE_TYPE) \
        --build-arg itag=latest \
        -f $(DF_RSTUDIO) . 2>&1 | tee build_$(DI_RSTUDIO).log
	$(DC) tag $(D_REP)$(DI_RSTUDIO):$(DT_RSTUDIO) $(D_REP)$(DI_RSTUDIO):latest
	touch $(DI_RSTUDIO).image

.SUFFIXES : .dfile .image .push

.image.push:
	@echo ">>> pushing $(D_REP)$*"
	$(DC) push $(D_REP)$*
	@touch $@

.dfile.image:
	@echo ">>> $(shell date)" building $(D_REP)$*:$(D_TAG) $<
	$(DB) -t $(D_REP)$*:$(D_TAG) $(DB_FLAGS) -f $< . > build_$*.log
	@touch $@

clean:
	@echo Deleting all images $(D_IMAGES_IMG)
	@rm -f $(D_IMAGES_IMG)
	@echo Deleting all pushes $(D_PUSH)
	@rm -f $(D_PUSH)
	@echo Deleting all logs
	@rm -f *.log
