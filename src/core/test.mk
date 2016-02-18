# If a test dir exists, assume we want to run tests
ifeq ($(wildcard test),)
test::
	$(verbose) :
test-clean::
	$(verbose) :
else
test::
	# Filter out ignored tests and run the TEST_TARGET
	$(foreach testmk,$(TEST_FILES), $(MAKE) -C $(TEST_DIR) -f $(shell basename $(testmk)) $(TEST_TARGET))

test-clean::
	echo test-clean
	# Clean up the container we created for the tests
	$(foreach container,$(shell docker ps -a | grep $(TAG) | awk '{print $1}'), $(shell docker rm -f $(container)))
endif
