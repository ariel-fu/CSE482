# odk_remake

Flutter CSE 482B Capstone Project. Re-implementing ODK.


## Description
In the realm of global health, Information and Computing Technologies (ICT) have emerged as powerful tools for improving health care delivery in low-resource settings. One notable example is the Open Data Kit (ODK), a free and open-source software designed to facilitate data collection and management in challenging environments. Despite its success, ODK is built on technologies from 2007, limiting its potential in today's technological landscape. This paper explores the modernization of ODK Collect as ODK 1.5 using Flutter, a contemporary framework. The new implementation aims to enhance functionality, streamline usability, and expand the platform's impact on health care delivery. Key improvements include a more user-friendly interface, cross-platform compatibility, and direct integration with Excel for data collection, bypassing the need for XML conversion. The project leverages Firebase for secure, scalable cloud storage, ensuring data accessibility and safety. This modernization not only preserves the core strengths of ODK but also adapts it to the needs of the modern world, offering a robust, versatile solution for digital data collection in resource-constrained environments. Future work wcan explore additional features like bi-directional communication, web-based options, and advanced data inputs to further enhance the platform's capabilities.

## Implementation
The majority of code written for this project is in the 'lib' folder where it is then subdivided further. 
Models -> form question and excel file formats
Screens -> start, complete, home, settings, etc.
Services -> parse data, user services
Theme -> for dark mode
Widgets -> excel item

