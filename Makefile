.PHONY: check fmt lint

black := black --line-length 100

check:
	mypy .
	pytest .

fmt:
	isort --recursive .
	autoflake --recursive --in-place --remove-all-unused-imports --remove-unused-variables .
	$(black) .

lint:
	flake8
	isort --recursive . --check-only
	$(black) --check .

tidy:
	find . -name '*~' -delete

clean: tidy
