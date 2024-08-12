# Document Scanner #

This package includes a document scanner implemented using OpenCV, with an automatic orientation detection feature for scanned images, leveraging both OpenCV and Tesseract.<br/>

## I- How to use the package? ##
### 1- Adding language data files ###
Create a folder named **assets** in the root of your project, and inside it, create another folder named **tessdata**. 
Then, place the language data files that you need into the **tessdata** folder.

### 2- Creating tessdata_config.json file ###
Create a file named tessdata_config.json inside the assets folder. 
This file must include the names of all the language data files. 

This is an example of how the file should look:
```json
{
  "files": [
    "ara.traineddata",
    "eng.traineddata",
    "fra.traineddata",
    "osd.traineddata"
  ]
}
```

### 3- Implementing the code ###
To implement the document scanner you just need to write this code inside your application:

```
DocumentScannerOcr( 
    onFinish: (ScannerResult scannerResult) {
        \\ write your own code
    }
),
```

## II- What does the package return? ##
The package returns a **ScannerResult** class that contains 3 parameters.

- **pdfBytes**:  A list of bytes representing the generated PDF including all scanned images (List<int>).

- **images**: A list of the scanned images (List<Uint8List>).

- **numberOfPages**: The total number of pages in the document.
