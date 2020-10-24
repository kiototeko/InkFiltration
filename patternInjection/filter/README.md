# Filter

* In **filter.sh** we find the actual implementation of a malicious filter
* **mime.types** is used to define the MIME types. We define here our custom MIME type in substitution to the pdf format.
* **mime.convs** is used normally to define conversions between MIME types, we use it here to force CUPS to transform documents with our defined custom MIME type into the pdf MIME type by passing the document through our malicious filter.
