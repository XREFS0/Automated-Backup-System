.PHONY: help test check install

help:
	@echo "Automated Backup System Makefile"
	@echo "================================"
	@echo "make check   - Run diagnostics check"
	@echo "make backup  - Run a backup manually"
	@echo "make restore - Launch interactive restore"
	@echo "make test    - Run test suite (if implemented)"

check:
	./backup-manager.sh diagnostics

backup:
	./backup-manager.sh backup

restore:
	./backup-manager.sh restore

test:
	./tests/run_tests.sh
