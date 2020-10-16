# InkFiltration: Using Inkjet Printers for Acoustic Data Exfiltration from Air-Gapped Networks

A covert channel can be established by leveraging the acoustic emissions of inkjet printers to exfiltrate information from an air-gapped network. In essence, malware installed on a computer with access to a printer can inject certain imperceptible patterns into all documents being sent to the printer, so as to control the printing process in such a way that an acoustic signal is generated which can be captured with a nearby smartphone.

The code consists of the follwing:

1. A series of programs used to inject the patterns into documents. These are located in the patternInjection directory.
1. The receiver code that was implemented both in MATLAB and for and Android smartphone

