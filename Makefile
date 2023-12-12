

resort-packages:
	@echo "Resorting packages..."
	python3 sort-packages.py app.txt
	python3 sort-packages.py luci.txt
	@echo "Done"
