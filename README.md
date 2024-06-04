# ODK cse482B
CSE 482B Capstone Project. Re-implementing ODK.


## Description
In the realm of global health, Information and Computing Technologies (ICT) have emerged as powerful tools for improving health care delivery in low-resource settings. One notable example is the Open Data Kit (ODK), a free and open-source software designed to facilitate data collection and management in challenging environments. Despite its success, ODK is built on technologies from 2007, limiting its potential in today's technological landscape. This paper explores the modernization of ODK Collect as ODK 1.5 using Flutter, a contemporary framework. The new implementation aims to enhance functionality, streamline usability, and expand the platform's impact on health care delivery. Key improvements include a more user-friendly interface, cross-platform compatibility, and direct integration with Excel for data collection, bypassing the need for XML conversion. The project leverages Firebase for secure, scalable cloud storage, ensuring data accessibility and safety. This modernization not only preserves the core strengths of ODK but also adapts it to the needs of the modern world, offering a robust, versatile solution for digital data collection in resource-constrained environments. Future work wcan explore additional features like bi-directional communication, web-based options, and advanced data inputs to further enhance the platform's capabilities.

## Roadmap
The development of our application for the capstone is complete. However, as we explored this space, we found many different areas to explore and build in. The following points are a few of the areas where we believe have the potential to be explored and the considerations for future iterations:

One additional feature to build onto ODK would be bi-directional communication between the user completing the survey and the user managing the surveys. Enhancing user engagement through bi-directional communication will allow for a more interactive experience. This will enable users to not only submit data but also receive feedback, creating a dynamic flow of information.

As we have seen before, many different mobile operating systems are being used in research, and our reimplemented version of ODK supports multiple systems. Another potential expansion along this avenue would be the revival of a web-based option. A web-based option will cater to users who prefer or require desktop access, increasing the application's versatility.

Outside of how the application could be improved, we also considered hardware modifications to the data collection process. Future versions could explore the integration of sensors and the collection of more complex data types, such as health indicators. This could provide more diverse data points in the dataset and give deeper insights.

One area that is lacking in digital data collection is how restricted the data is presented. For example, with paper data records, the surveyor could add notes within the margins where the response is relevant to the research but does not fit within one of the questions. For future iterations of ODK, more flexible data inputs can be explored. With more flexible data inputs, there would also need to be a well-established methodology with existing data visualization tools. The methodology should ensure that data is also presented in an insightful manner. 

Another interesting area of exploration came up when we were talking to Dr. Hartung. Introducing gamification elements into data collection could incentivize user participation and improve the quantity of data gathered. However, there was a concern that users would try to “game” the system in order to win more awards. A potential area of research would be to figure out how to create robust validation methods to help identify outliers and anomalies, ensuring data integrity.

We also considered exploring the datasets themselves, and we propose two changes to the dataset’s inner-relationships and data gaps. Oftentimes, there are relationships between different surveys. Exploring the relational behavior between different questionnaires may uncover patterns and correlations, enhancing the data's richness. We also considered the feasibility of pulling data from web sources to enrich our datasets. This could help fill any gaps in the data and provide a better overview of any relationships presented by the data.

Finally, one common theme we saw with prior versions of ODK was that it was a standalone service. Its framework was not supported by a large tech ecosystem that actively supported backwards compatibility. Researchers with different needs had to contact the developers to identify whether it was possible to program a feature for their research use case. Many features in ODK, such as inputting data through Excel, were added once the need arises. Moreover, it takes many man-hours, possibly more hours than the researchers have allocated, to implement, test, and deploy a new feature built on ODK. A potential area of exploration would be to create a more generalizable version of ODK that could adapt to various data collection needs, streamline the research process, and improve the researchers’ experience with ODK. Transitioning from siloed operations to a modular framework could help with building new features faster and enhance the system's adaptability.

## Authors and acknowledgment
Authors: Mitchell Ly, Ariel Fu, Aidan Petta, Annalisa Mueller-Eberstein

Acknowledgements: To Richard Anderson and Lisa Orii, for the 1:1s, advice, and arranging guest speakers for our class. Thank you to Waylon Brunette and Carl Hartung for reviewing our proposal for ODK Collect 1.5 and providing useful context for the development of and need for ODK.

## Project status
Complete. Feel free to develop further on this MVP.
