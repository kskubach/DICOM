## DICOM Demo
​
One of the challenges of creating a DICOM message is how to implement putting data in the correct place. Part of it is by inserting the data in the specific DICOM tags, while the other is to insert binary data such as a picture - In this article I will explain both.

To create a DICOM message, you can either use the  EnsLib.DICOM.File class (to create a DICOM file) or the  EnsLib.DICOM.Document class (to create a message that can be sent to PACS directly). In either case, the SetValueAt method will allow you to add your data to the DICOM tags.

A DICOM message consists of two constituent parts, CommandSet and the DataSet.
The CommandSet contains DICOM elements which contain details about the characteristics of the DataSet, while the DataSet contains the data itself - patient's demographic, image etc.

To update the tags in the CommandSet or the DataSet, simply state the value and the name of the property you wish to update using the SetValueAt method:
```
set tstatus=tDoc.SetValueAt("1.2.840.10008.5.1.4.1.1.7","CommandSet.MediaStorageSOPClassUID")
set tstatus=tDoc.SetValueAt("1.2.392.200059.1.11.11084587.3.35820032317.2.1.56","CommandSet.MediaStorageSOPInstanceUID") 
set tstatus=tDoc.SetValueAt("1.2.276.0.7230010.3.0.3.6.4","CommandSet.ImplementationClassUID") 
set tstatus=tDoc.SetValueAt("OFFIS_DCMTK_364","CommandSet.ImplementationVersionName") 
set tstatus=tDoc.SetValueAt("Morgan^Gina^G","DataSet.PatientName") 
set tstatus=tDoc.SetValueAt("2751","DataSet.PatientID")
set tstatus=tDoc.SetValueAt("19810816","DataSet.PatientBirthDate")	
set tstatus=tDoc.SetValueAt("F","DataSet.PatientSex") 
```
you can either use the property name or the property tag. For example, those 2 commands are updating the same tag:
```
	set tstatus=tDoc.SetValueAt("Olympus","DataSet.Manufacturer")		
	set tstatus=tDoc.SetValueAt("Olympus","DataSet.(0008,0070)") 
```
Once the message is created and transferred to PACS as a document, you can see its data as part of the trace (note that binary data cannot be seen):


![alt text](image(10184)-1.png)

In order to add the binary data for the image, it is more complicated that just putting the data in a specific tag, because it needs to be structured in a specific way and measured appropriately. This is why after updating the tags and saving the document, we need to open it as a simple binary file and add the image data at the end of it in a specific manner.

The image is part of the PixelData property in tag (7FE0,0010).

This tag is a sequence - DICOM allows a DataSet to contain other nested DataSets, which are encoded as “sequences”. The point of this structure is to allow repeating groups of data, so whilst such sequences often only contain a single DataSet, the format is defined such that each sequence consists of a set of DataSets.

This structure can be used in recursion, and some DICOM scenarios might use sequences nested 5 or 6 deep.



 ![alt text](image(10183).png)

The demo shows a sample of creating a DICOM document with an image in it. The patient's demographic and other details are just for the sake of teh sample. To run this demo, simply put a JPG file in a directory, configure the directory name in the 'FileStorageDirectory' property in the business operation's settings:



 ![alt text](image(10185).png)

and run the Business Process. After its completion, you'll see a new dcm file in the same directory where your JPG file was. open it in a DICOM viewer and you'll see the DICOM tags as well as the image in it:

![alt text](image(10186).png)

Here is a quick video demo showing the whole process:


To run the demo:
1. Configure the 'FileStorageDirectory' property in the business operation's settings to point to a local existing directory.
2. Put the 'NormalColon.jpg' file in that directory.
3. Start the production
4. Invoke the Business process (Ations->Test). No data needs to be sent, just an empty Ens.StringRequest message.
5. Look at the visual trace - the first call to the business operation created the DICOM document and update its tags (incuding the JPG dimentions). The second call accepts the message, creates and saves a DICOM file from it, and than opens the file as a binary file to add the image data as a sequence at the file's end.
6. Check the existing files in the directory - a new file should be created with a '.dcm' suffix.
7. Open the file in a DICOM viewer and see the DICOM tags and image data.

Good luck!

Keren.

 

 



​