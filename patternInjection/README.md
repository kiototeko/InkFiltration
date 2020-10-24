# Pattern Injection

* **randomBits.sh** generates any amount of pages with the specified modulation. It generates a random bit payload.
* **intercalate.sh** is used to intercalate pages of the document with the two distinct modulations.
* **genericPattern.py** is used to map bits to the specific injection patterns.
* **filter.sh** is an example of a malicious filter.
* **Layouts** is the directory with all the different layouts used.

To inspect and modify PDF files, this project makes use of https://github.com/jesparza/peepdf with a small modification.
