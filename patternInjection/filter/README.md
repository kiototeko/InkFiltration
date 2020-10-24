# Filter

* In **filter.sh** we find the actual implementation of a malicious filter. This filter should be named **pdfnew2pdf**, according to how we defined it in **mime.convs** file.
* **mime.types** is used to define the MIME types. We define here our custom MIME type in substitution to the pdf format.
* **mime.convs** is used normally to define conversions between MIME types, we use it here to force CUPS to transform documents with our defined custom MIME type into the pdf MIME type, by passing the document through our malicious filter.

A copy of peepdf and genericPattern.py should be placed on the **/tmp** directory for the filter to work. A file with a sequence of 0 and 1 bits (the data to be exfiltrated) should be also placed in **/tmp**.
