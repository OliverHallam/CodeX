CodeX
=====

*CodeX* is an XML based tool which generates beautiful HTML code documentation from comments in your source code.

*CodeX* is developed in a combination of C#, MSBuild and XSLT 2.0.  [XMLPrime][1] is used in order to perform the XSLT2 transformations, and so a copy is currently required in order to build the documentation.  The evaluation version of XMLPrime is sufficient to evaluate *CodeX*.


Features
--------

The first official release of the product will be able to produce MSDN style documentation from XML code documentation tags (`///`) in C# projects (a la [Sandcastle][3]).  Configuration of the documentation will be performed directly from within Visual Studio.

The main goals of this project are to be:

- **Beautiful** documentation.
- **Easy to use**.  You should be able to set up documentation for your product in 10 minutes.
- **Flexible**.
- **Extensible**.  It should be easy to add support for new themes, languages and custom documentation styles with XSLT2.
- **Integrated** with Visual Studio.
- **Fast**.  Ideally it should be possible to edit code documentation interactively.
- **Well documented** :)


History
-------

The source code for this project originated as an internal tool which was developed in order to generate the [XmlPrime API documentation][2], and as a means for testing [XmlPrime][1] itself.  The source code has been kindly donated to me by my former employer.

[1]:http://www.xmlprime.com/
[2]:http://www.xmlprime.com/doc/
[3]:http://sandcastle.codeplex.com/