# Shakespeare Demo Application

This application is designed to run on MarkLogic Server 3.1 and later.

To run the application, you must :
   a) have MarkLogic Server installed
   b) download the XML source 
   b) configure MarkLogic server as described below.

## Getting Started
To download the Shakespeare XML Source for the Plays, download
the zip file containing the source:

   The shakespeare XML source is available via the following URL:

     ```
     http://www.oasis-open.org/cover/bosakShakespeare200.html
     ```
     
   This points to a zip file at the following location:
   
     ```
     http://metalab.unc.edu/bosak/xml/eg/shaks200.zip
     ```
     
  The XML source is subject to the copyright stated in the XML files.

## Setting up the MarkLogic Server Configuration:

1) Create a forest (for example, named bill).

2) Create a database (for example, named bill).

3) Attach the forest to the database.

4) (optional) In addition to the default options, add 'word positions' to the 
   indexing options for the database.  This will improve the performance of
   phrase searches.

5) (optional) Add SCENE as a fragment root for the database.  This will 
   improve the performance of the application.

6) Create an HTTP App Server that accesses the new database. The following 
   are sample configuration values for the HTTP server (you can use these
   or choose different ones):

   server name:  bill
   root:         bill
   port:         8060
   modules:      filesystem
   database:     bill
   
7) Copy the Shakespeare application files (.xqy, .html, .js, .gif, .jpg) to 
   the App Server root on your host (for example, to the directory
   c:\Program Files\MarkLogic\bill).

8) Download and unzip the Shakespeare XML source from the URL above.

9) Modify the $playdir variable in the load_bill.xqy script to point to the
   directory in which you have copied the Shakespeare XML files.  On UNIX
   systems, make sure the directory and its parent directory is readable by 
   the daemon user (or the user under which MarkLogic Server runs).

10) Execute the load_bill.xqy script to load the shakespeare XML into
    the database.  For example, run the following in a browser:

    ```
    http://localhost:8060/load_bill.xqy
    ```

    NOTE: Make sure the user who executes this module has the necessary 
          prvileges to load documents into the database and to execute 
          the privileged functions in the script.  

11) Add the COMEDY, TRAGEDY, and HISTORY properties to the XML documents
    by running the add_props.xqy script.  For example, run the following 
    in a browser:

    ```
    http://localhost:8060/add_props.xqy
    ```

12) You can now run the Shakespeare sample application by accessing the
    App Server root.  For example:

    ```
    http://localhost:8060/
    ```

### About the Shakespeare demo application:

The Shakespeare demo application allows you to search across all of the 
Shakespeare plays and display the plays scene-by-scene.  It includes a 
master table of contents, a search page allowing simple searches with 'and'
boolean logic, and an advanced search page which adds near searches to 
the search options.  In any search, you can enter double-quotes around a 
phrase to indicate a phrase search (for example, "to be or not to be" will 
return a single hit from Hamlet).

The application is written in XQuery, with some javascript to help with the
table of contents tree control.  The XQuery code sends xhtml pages to 
display on the browser.  It is intended as a simple sample of an
application you can write in MarkLogic Server, and demonstrates some common
design patterns used in MarkLogic applications.  It includes all of the 
code for the application.  Feel free to play around and modify the code
to suit your needs and to learn how it works.

Some of the features and design patterns of the application include:

    * generating a table of contents from a content set
    * dynamically transforming content from its original XML structure
      to xhtml (using a recursive typeswitch)
    * full text search, including a search box and a search results page
    * proximity (cts:near-query) search page
    * a simple query parser (parses double-quoted text as phrases)
    * some interesting examples of text highlighting using cts:highlight
    * dynamically counts and displays the line numbers
    * using properties to store metadata
    * and much more....

### The following files are included in the distribution:

README.txt         this file
add_props.xqy      XQuery script to update the XML documents, adding the
                   appropriate property to each document (COMEDY, TRAGEDY, 
                   HISTORY)
contents.xqy       XQuery main module to display the table of contents
default.xqy        redirects to the start point of the application
display.xqy        XQuery main module to display an entire play on one page
display-lib.xqy    XQuery library module containing the display functions
displayScene       XQuery main module to display the plays one scene at a time
frame.html         html frame layout
load_bill.xqy      XQuery load script to load the XML source
search.xqy         XQuery main module to display the search results page
searchAdv.xqy      XQuery main module to display the proximity search 
                   results page
search-lib.xqy     XQuery library module containing the search functions
start.xqy          XQuery main module to display the initial page with links
                   to all the plays
tree.js            javascript file to support table of contents tree control
*.css,*.jpg,*.gif  supporting images and stylesheets

