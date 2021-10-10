# Pandoc Templates for Scottish Government

Pandoc templates for converting documents. Intended for use by the Analytical Data Management team.

Currently, templates are provided for conversion to DOCX and PDF format.

Using these Pandoc templates, your documents will:

- Conform to Scottish Government accessibility guidelines.
- Be uniform, consistent, and reproducible.
- Be readable on most devices.

## Windows Batch File

The provided Windows batch file -- pandoc.bat -- ensures that docuements are converted using the provided templates, and a consistent set of rules.

The batch file is intended to make Pandoc easy to use. Simply create a shortcut to the batch file in the directory containing your documents. Run the shortcut to convert your documents.

### Parameters

If you wish to change the default parameters, the following parameters can be changed by adding arguments to the shortcut:

- `-i=...` Input directory. Default: Current directory.
- `-o=...` Output directory. Default: Current directory.
- `-n=...` Output name. Default: Name of the current directory.
- `-t=...` Table of contents depth. Default: 1. Set to 0 (zero) to disable the table of contents.
- `-p=...` Path to the Pandoc executable. Default: "C:\Program Files\Pandoc\pandoc.exe".

## Thanks

The parameter reading function was provided by Evan Kennedy on Stack Overflow \([Link](https://stackoverflow.com/questions/26551/how-can-i-pass-arguments-to-a-batch-file/35445653#35445653)).
