Include EnsDICOM

Class DICOMDemo.BO.File Extends Ens.BusinessOperation [ ClassType = "", ProcedureBlock ]
{

Parameter ADAPTER = "Ens.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// This is the directory where the local files will be stored
Parameter SETTINGS = "FileStorageDirectory";

/// This is the directory where the incoming DICOM files will be stored
Property FileStorageDirectory As %String(MAXLEN = "");

Method CreateDICOMDocument(pRequest As Ens.StringRequest, Output pResponse As EnsLib.DICOM.Document) As %Status
{
	set tStatus=$$$OK
	set date=##class(Ens.Util.FunctionSet).CurrentDateTime("%Y%m%d")
	set time=##class(Ens.Util.FunctionSet).CurrentDateTime("%H%M%S")

	set pResponse=##class(EnsLib.DICOM.Document).%New()
	try {

		// CommandSet tags
		
		Set tOutMsgType =$$$Str2MsgTyp("N-CREATE-RSP")	
		Set tStatus=pResponse.SetValueAt("1.2.840.10008.5.1.4.31","CommandSet.AffectedSOPClassUID") 								// 0000,0002
		Set tStatus=pResponse.SetValueAt(tOutMsgType,"CommandSet.CommandField")														// 0000,0100
		Set tStatus=pResponse.SetValueAt(0,"CommandSet.Status") 																	// 0000,0900
		set tstatus=pResponse.SetValueAt("1.2.840.10008.5.1.4.1.1.7","CommandSet.MediaStorageSOPClassUID") 							// 0002,0002
		set tstatus=pResponse.SetValueAt("1.2.392.200059.1.11.11084587.3.35820032317.2.1.56","CommandSet.MediaStorageSOPInstanceUID")	// 0002,0003
		set tstatus=pResponse.SetValueAt("1.2.276.0.7230010.3.0.3.6.4","CommandSet.ImplementationClassUID")							// 0002,0012
		set tstatus=pResponse.SetValueAt("OFFIS_DCMTK_364","CommandSet.ImplementationVersionName")									// 0002,0013
		
		// DataSet tags
		
		set tstatus=pResponse.SetValueAt("ISO_IR 100","DataSet.SpecificCharacterSet")												// 0008,0005
		set tstatus=pResponse.SetValueAt("ORIGINAL\PRIMARY","DataSet.ImageType")													// 0008,0008
		set tstatus=pResponse.SetValueAt("1.2.840.10008.5.1.4.1.1.7","DataSet.SOPClassUID")											// 0008,0016
		set tstatus=pResponse.SetValueAt("1.2.392.200059.1.11.11084587.3.35820032317.2.1.56","DataSet.SOPInstanceUID")				// 0008,0018
		set tstatus=pResponse.SetValueAt(date,"DataSet.StudyDate")																	// 0008,0020
		set tstatus=pResponse.SetValueAt(date,"DataSet.SeriesDate")																	// 0008,0021
		set tstatus=pResponse.SetValueAt(date,"DataSet.AcquisitionDate")															// 0008,0023
		set tstatus=pResponse.SetValueAt(time,"DataSet.StudyTime")																	// 0008,0030
		set tstatus=pResponse.SetValueAt(time,"DataSet.SeriesTime")																	// 0008,0031
		set tstatus=pResponse.SetValueAt(time,"DataSet.AcquisitionTime")															// 0008,0033
		set tstatus=pResponse.SetValueAt("ES","DataSet.Modality")																	// 0008,0060
		set tstatus=pResponse.SetValueAt("DV","DataSet.ConversionType")																// 0008,0064
		set tstatus=pResponse.SetValueAt("Olympus","DataSet.Manufacturer")															// 0008,0070
		set tstatus=pResponse.SetValueAt("Boston Lab","DataSet.InstitutionName")													// 0008,0080
		set tstatus=pResponse.SetValueAt("ABC33","DataSet.StationName")																// 0008,1010
		set tstatus=pResponse.SetValueAt("Colonoscopy","DataSet.StudyDescription")													// 0008,1030
		set tstatus=pResponse.SetValueAt("Michaels^Joan^O^DR","DataSet.(0008,1048)")												// 0008,1048  DataSet.Physician(s)ofRecord
		set tstatus=pResponse.SetValueAt("Olympus Endoscopy Information System","DataSet.(0008,1090)")								// 0008,1090  DataSet.Manufacturer'sModelName
		set tstatus=pResponse.SetValueAt("Morgan^Gina^G","DataSet.PatientName")														// 0010,0010
		set tstatus=pResponse.SetValueAt("2751","DataSet.PatientID")																// 0010,0020
		set tstatus=pResponse.SetValueAt("19810816","DataSet.PatientBirthDate")														// 0010,0030
		set tstatus=pResponse.SetValueAt("F","DataSet.PatientSex")																	// 0010,0040
		set tstatus=pResponse.SetValueAt("1751.2751.20200323104855","DataSet.StudyInstanceUID")										// 0020,000D
		set tstatus=pResponse.SetValueAt("1.2.392.200059.1.11.11084587.2.35820032317.2","DataSet.SeriesInstanceUID")				// 0020,000E
		set tstatus=pResponse.SetValueAt("Colonoscopy Series Tests","DataSet.SeriesDescription")									// 0008,103E
		set tstatus=pResponse.SetValueAt("358","DataSet.StudyID")																	// 0020,0010
		set tstatus=pResponse.SetValueAt("1","DataSet.SeriesNumber")																// 0020,0011
		set tstatus=pResponse.SetValueAt("1","DataSet.InstanceNumber")																// 0020,0013
		set tstatus=pResponse.SetValueAt("3","DataSet.SamplesPerPixel")																// 0028,0002
		set tstatus=pResponse.SetValueAt("Colonoscopy","DataSet.(0040,0275)[1].(0040,0007)")										// Scheduled Procedure Step Description 
		
		// Get jpeg file - just the first JPG file in the directory

		set tPath=..FileStorageDirectory
		Set tFileSet = ##class(%ResultSet).%New("%File:FileSet")
		Do tFileSet.%Execute(tPath,"*.jpg")
		while tFileSet.%Next() {
			if tFileSet.Type="D" continue
			Set tFileName = tFileSet.Name
		}

		// Get and update the JPG dimentions

		if tFileName'="" {
			set tHeight=0
			set tWidth=0
			do ..GetJPGDimensions(tFileName,.tHeight,.tWidth)

			set tstatus=pResponse.SetValueAt(tHeight,"DataSet.Rows")																// 0028,0010
			set tstatus=pResponse.SetValueAt(tWidth,"DataSet.Columns")																// 0028,0011
			set tstatus=pResponse.SetValueAt("8","DataSet.BitsAllocated")															// 0028,0100
			set tstatus=pResponse.SetValueAt("8","DataSet.BitsStored")																// 0028,0101
			set tstatus=pResponse.SetValueAt("7","DataSet.HighBit")																	// 0028,0102
			set tstatus=pResponse.SetValueAt("0","DataSet.PixelRepresentation")														// 0028,0103
		}	

	}
	catch Err {
		$$$TRACE($system.Status.GetErrorText(Err.AsStatus()))
	}
	Quit tStatus
}

Method AddJPG(pRequest As EnsLib.DICOM.Document, Output pResponse As Ens.StringResponse) As %Status
{
	set tStatus=$$$OK

	set pResponse=##class(Ens.StringResponse).%New()
	try {
		
		Set tDoc=##class(EnsLib.DICOM.File).%New()

		do ##class(EnsLib.DICOM.File).CreateFromDocument(pRequest,.tDoc)
		set tDoc.TransferSyntax = "1.2.840.10008.1.2.4.50"				// JPEG Baseline: Default Transfer Syntax for Lossy JPEG 8-bit Image Compression
		
		// Save the DICOM file with a '.DCM' suffix
		
		Set tFileName=##class(%File).NormalizeDirectory(..FileStorageDirectory)_"JPG_"_(##class(%Stream.FileBinary).NewFileName("dcm"))
		set tSC = tDoc.Save(tFileName)		
		

		// re-open the DICOM file as a binary file to add the JPG binary data at the end
		
		set tDicomFile = ##class(%Stream.FileBinary).%New()
		do tDicomFile.LinkToFile(tFileName)
		do tDicomFile.MoveToEnd()
		
		// Get the first JPG file in the directory
		
		set tJPGFileName=""
		set tPath=..FileStorageDirectory
		Set tFileSet = ##class(%ResultSet).%New("%File:FileSet")
		Do tFileSet.%Execute(tPath,"*.jpg")
		while tFileSet.%Next() {
			if tFileSet.Type="D" continue
			Set tJPGFileName = tFileSet.Name
		}

		if tJPGFileName="" {
			do tDicomFile.%Save() 
			set pResponse.StringValue="No JPG files found. Created DICOM file '"_tFileName_"' without an image."
			quit
		}

		// Open the JPG file
		
	 	set tStream = ##class(%Stream.FileBinary).%New()
		do tStream.LinkToFile(tJPGFileName)

		// Update the PixelData tag (7FE0,0010) 
		
		do tDicomFile.Write($C($ZH("E0"),$ZH("7F"),$ZH("10"),$ZH("00"))) // (7FE0,0010) = Pixel Data tag
		do tDicomFile.Write($C($ZH("4F"),$ZH("42"),$ZH("00"),$ZH("00"))) // VR (Value Representation) = OB (Other Byte String)
		do tDicomFile.Write($C($ZH("FF"),$ZH("FF"),$ZH("FF"),$ZH("FF"))) // undefined length
		
		// Sequence Item start - with empty length
		
		do tDicomFile.Write($C($ZH("FE"),$ZH("FF"),$ZH("00"),$ZH("E0"))) // Item Start (FFFE,00E0)
		do tDicomFile.Write($C($ZH("00"),$ZH("00"),$ZH("00"),$ZH("00"))) // length=0
		
		// image file size - must have an even number of bytes (when using OB representation)
		
		set tSize = tStream.Size
		set tOdd = tSize # 2
		
		//if the single fragment has an odd number of bytes, add one to the size
		
		if tOdd set tSize = tSize + 1 
		set tSizeStr = "0000000"_$ZH(tSize)
		set tSizeStr = $E(tSizeStr,($L(tSizeStr)-7),$L(tSizeStr))
		
		// Sequence Item start with the actual JPG image size length
		
		do tDicomFile.Write($C($ZH("FE"),$ZH("FF"),$ZH("00"),$ZH("E0"))) // Item Start (FFFE,00E0)
		do tDicomFile.Write($C($ZH($E(tSizeStr,7,8)),$ZH($E(tSizeStr,5,6)),$ZH($E(tSizeStr,3,4)),$ZH($E(tSizeStr,1,2))))
		
		// add the jpg image binary data
		
		do tDicomFile.CopyFrom(tStream)
		
		//if the single fragment has an odd number of bytes, pad it with FFH
		
		if tOdd do tDicomFile.Write($C($ZH("FF")))
		
		// Sequence close Item
		
		do tDicomFile.Write($C($ZH("FE"),$ZH("FF"),$ZH("DD"),$ZH("E0")))  // Item close (FFFE,E0DD)
		do tDicomFile.Write($C($ZH("00"),$ZH("00"),$ZH("00"),$ZH("00")))  // length=0
		
		do tDicomFile.%Save() 
		set pResponse.StringValue="Created DICOM file '"_tFileName_"' with '"_tJPGFileName_"' in it."

	}
	catch Err {
		set pResponse.StringValue=$system.Status.GetErrorText(Err.AsStatus())
	}
	Quit tStatus
}

Method CreateDICOMJPG(pRequest As Ens.StreamContainer, Output pResponse As Ens.StringResponse) As %Status
{
	set tStatus=$$$OK
	set date=##class(Ens.Util.FunctionSet).CurrentDateTime("%Y%m%d")
	set time=##class(Ens.Util.FunctionSet).CurrentDateTime("%H%M%S")

	set pResponse=##class(Ens.StringResponse).%New()
	try {
		Set tDoc=##class(EnsLib.DICOM.File).%New()
		set tDoc.TransferSyntax = "1.2.840.10008.1.2.4.50"
		set tstatus=tDoc.SetValueAt("1.2.840.10008.5.1.4.1.1.7"	,"MetaData.MediaStorageSOPClassUID") 							// 0002,0002
		set tstatus=tDoc.SetValueAt("1.2.392.200059.1.11.11084587.3.35820032317.2.1.56","MetaData.MediaStorageSOPInstanceUID")	// 0002,0003
		set tstatus=tDoc.SetValueAt("1.2.276.0.7230010.3.0.3.6.4","MetaData.ImplementationClassUID")							// 0002,0012
		set tstatus=tDoc.SetValueAt("OFFIS_DCMTK_364","MetaData.ImplementationVersionName")										// 0002,0013
		set tstatus=tDoc.SetValueAt("ISO_IR 100","DataSet.SpecificCharacterSet")												// 0008,0005
		set tstatus=tDoc.SetValueAt("ORIGINAL\PRIMARY","DataSet.ImageType")														// 0008,0008
		set tstatus=tDoc.SetValueAt("1.2.840.10008.5.1.4.1.1.7","DataSet.SOPClassUID")											// 0008,0016
		set tstatus=tDoc.SetValueAt("1.2.392.200059.1.11.11084587.3.35820032317.2.1.56","DataSet.SOPInstanceUID")				// 0008,0018
		
		set tstatus=tDoc.SetValueAt(date,"DataSet.StudyDate")																	// 0008,0020
		set tstatus=tDoc.SetValueAt(date,"DataSet.SeriesDate")																	// 0008,0021
		set tstatus=tDoc.SetValueAt(date,"DataSet.AcquisitionDate")																// 0008,0023
		set tstatus=tDoc.SetValueAt(time,"DataSet.StudyTime")																	// 0008,0030
		set tstatus=tDoc.SetValueAt(time,"DataSet.SeriesTime")																	// 0008,0031
		set tstatus=tDoc.SetValueAt(time,"DataSet.AcquisitionTime")																// 0008,0033
		set tstatus=tDoc.SetValueAt("ES","DataSet.Modality")																	// 0008,0060
		set tstatus=tDoc.SetValueAt("DV","DataSet.ConversionType")																// 0008,0064
		set tstatus=tDoc.SetValueAt("Olympus","DataSet.Manufacturer")															// 0008,0070
		set tstatus=tDoc.SetValueAt("Boston Lab","DataSet.InstitutionName")														// 0008,0080
		set tstatus=tDoc.SetValueAt("ABC33","DataSet.StationName")																// 0008,1010
		set tstatus=tDoc.SetValueAt("Colonoscopy","DataSet.StudyDescription")													// 0008,1030
		set tstatus=tDoc.SetValueAt("\Michaels^Joan^O^DR","DataSet.(0008,1048)")												// 0008,1048  DataSet.Physician(s)ofRecord
		
		set tstatus=tDoc.SetValueAt("Olympus Endoscopy Information System","DataSet.(0008,1090)")								// 0008,1090  DataSet.Manufacturer'sModelName
		set tstatus=tDoc.SetValueAt("Morgan^Gina^G","DataSet.PatientName")														// 0010,0010
		set tstatus=tDoc.SetValueAt("2751","DataSet.PatientID")																	// 0010,0020
		set tstatus=tDoc.SetValueAt("19810816","DataSet.PatientBirthDate")														// 0010,0030
		set tstatus=tDoc.SetValueAt("F","DataSet.PatientSex")																	// 0010,0040
		set tstatus=tDoc.SetValueAt("1751.2751.20200323104855","DataSet.StudyInstanceUID")										// 0020,000D
		set tstatus=tDoc.SetValueAt("1.2.392.200059.1.11.11084587.2.35820032317.2","DataSet.SeriesInstanceUID")					// 0020,000E
		set tstatus=tDoc.SetValueAt("Colonoscopy Series Tests","DataSet.SeriesDescription")										// 0008,103E
		set tstatus=tDoc.SetValueAt("358","DataSet.StudyID")																	// 0020,0010
		set tstatus=tDoc.SetValueAt("1","DataSet.SeriesNumber")																	// 0020,0011
		set tstatus=tDoc.SetValueAt("1","DataSet.InstanceNumber")																// 0020,0013
		set tstatus=tDoc.SetValueAt("3","DataSet.SamplesPerPixel")																// 0028,0002
		
		// Get jpeg dimentions
		set tHeight=0
		set tWidth=0
		do ..GetJPGDimensions(pRequest,.tHeight,.tWidth)

		set tstatus=tDoc.SetValueAt(tHeight,"DataSet.Rows")																		// 0028,0010
		set tstatus=tDoc.SetValueAt(tWidth,"DataSet.Columns")																	// 0028,0011
		set tstatus=tDoc.SetValueAt("8","DataSet.BitsAllocated")																// 0028,0100
		set tstatus=tDoc.SetValueAt("8","DataSet.BitsStored")																	// 0028,0101
		set tstatus=tDoc.SetValueAt("7","DataSet.HighBit")																		// 0028,0102
		set tstatus=tDoc.SetValueAt("0","DataSet.PixelRepresentation")															// 0028,0103
		set tstatus=tDoc.SetValueAt("Colonoscopy","DataSet.(0040,0275)[1].(0040,0007)")											// Scheduled Procedure Step Description 
		
		// Save the DICOM file with a DCM suffix
		Set tFileName=##class(%File).NormalizeDirectory(..FileStorageDirectory)_"JPG_"_(##class(%Stream.FileBinary).NewFileName("dcm"))
		set tSC = tDoc.Save(tFileName)		
		
		// re-open the DICOM file as a binary file to add the JPG binary data at the end
		set tDicomFile = ##class(%Stream.FileBinary).%New()
		do tDicomFile.LinkToFile(tFileName)
		do tDicomFile.MoveToEnd()
		
		// (7FE0,0010) PixelData
		do tDicomFile.Write($C($ZH("E0"),$ZH("7F"),$ZH("10"),$ZH("00")))
		do tDicomFile.Write($C($ZH("4F"),$ZH("42"),$ZH("00"),$ZH("00"))) // VR
		do tDicomFile.Write($C($ZH("FF"),$ZH("FF"),$ZH("FF"),$ZH("FF"))) // undefined length
		
		// Sequence Item
		do tDicomFile.Write($C($ZH("FE"),$ZH("FF"),$ZH("00"),$ZH("E0")))
		do tDicomFile.Write($C($ZH("00"),$ZH("00"),$ZH("00"),$ZH("00"))) // length
		
		// image file size
		set tSize = pRequest.Stream.Size
		set tOdd = tSize # 2
		//if the single fragment has an odd number of bytes, add one to the size
		if tOdd set tSize = tSize + 1 
		set tSizeStr = "0000000"_$ZH(tSize)
		set tSizeStr = $E(tSizeStr,($L(tSizeStr)-7),$L(tSizeStr))
		
		// Sequence Item
		do tDicomFile.Write($C($ZH("FE"),$ZH("FF"),$ZH("00"),$ZH("E0")))
		do tDicomFile.Write($C($ZH($E(tSizeStr,7,8)),$ZH($E(tSizeStr,5,6)),$ZH($E(tSizeStr,3,4)),$ZH($E(tSizeStr,1,2))))
		
		// add the jpg image binary data
		do tDicomFile.CopyFrom(pRequest.Stream)
		
		//if the single fragment has an odd number of bytes, pad it with FFH
		if tOdd do tDicomFile.Write($C($ZH("FF")))
		
		// Sequence Delimitation Item
		do tDicomFile.Write($C($ZH("FE"),$ZH("FF"),$ZH("DD"),$ZH("E0")))
		do tDicomFile.Write($C($ZH("00"),$ZH("00"),$ZH("00"),$ZH("00")))
		
		do tDicomFile.%Save() 
		kill tDoc
	

	}
	catch Err {
		set pResponse.StringValue=$system.Status.GetErrorText(Err.AsStatus())
	}
	Quit tStatus
}

ClassMethod GetJPGDimensions(pFileName As %String(MAXLEN=100), Output pHeight As %Integer, Output pWidth As %Integer) As %Status
{
	set tSC = $$$OK
 	set pHeight = ""
 	set pWidth = ""
 	set tStream = ##class(%Stream.FileBinary).%New()
	do tStream.LinkToFile(pFileName)
 	set tSC = tStream.Rewind()
	quit:$$$ISERR(tSC) tSC
 	set tLen = tStream.Size
 	set tString = tStream.Read(.tLen,.tSC)
	quit:$$$ISERR(tSC) tSC
 	if (tLen = tStream.Size) {
		if ($ZH($A(tString,1)) = "FF") && ($ZH($A(tString,2)) = "D8") && ($ZH($A(tString,3)) = "FF") && ($ZH($A(tString,4)) = "E0") {
		 	if ($E(tString,7) = "J") && ($E(tString,8) = "F") && ($E(tString,9) = "I") && ($E(tString,10) = "F") && ($ZH($A(tString,11)) = "0") {
			 	set tBlockSize = ($A(tString,5) * 256) + $A(tString,6)
				set tPointer = 5
				while (tPointer <= tLen) {
					set tPointer = tPointer + tBlockSize
					if (tPointer < tLen) {
						if ($ZH($A(tString,tPointer)) = "FF") {
							//Added check for "C2" for "Progressive" JPEG's
							if ($ZH($A(tString,tPointer+1)) = "C0") || ($ZH($A(tString,tPointer+1)) = "C2") {
								set pHeight = ($A(tString,tPointer+5) * 256) + $A(tString,tPointer+6)
								set pWidth = ($A(tString,tPointer+7) * 256) + $A(tString,tPointer+8)
							} else {
								set tPointer = tPointer + 2
								set tBlockSize = ($A(tString,tPointer) * 256) + $A(tString,tPointer+1)
							}
						}
					}
				}
		 	}	
		}
 	}
	if (pHeight = "") && (pWidth = "") {
		set tSC = ##class(%SYSTEM.Status).Error(5001,"Could not find dimensions")
	}
 	quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest">
		<Method>CreateDICOMDocument</Method>
	</MapItem>
	<MapItem MessageType="EnsLib.DICOM.Document">
		<Method>AddJPG</Method>
	</MapItem>
</MapItems>
}

}
