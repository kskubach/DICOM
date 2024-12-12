Class DICOMDemo.BP.CreateDICOM Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.StringRequest' response='Ens.StringResponse' height='2000' width='2000' >
<context>
<property name='DICOMDoc' type='EnsLib.DICOM.Document' instantiate='0' />
</context>
<sequence xend='200' yend='450' >
<call name='Create DICOM Document' target='DICOMDemo.BO.File' async='0' xpos='200' ypos='250' >
<annotation><![CDATA[Create a DICOM document]]></annotation>
<request type='Ens.StringRequest' >
<assign property="callrequest" value="request" action="set" languageOverride="" />
</request>
<response type='EnsLib.DICOM.Document' >
<assign property="context.DICOMDoc" value="callresponse" action="set" languageOverride="" />
</response>
</call>
<call name='JPG + DICOM File' target='DICOMDemo.BO.File' async='0' xpos='200' ypos='350' >
<annotation><![CDATA[Add JPG and Create DICOM File]]></annotation>
<request type='EnsLib.DICOM.Document' >
<assign property="callrequest" value="context.DICOMDoc" action="set" languageOverride="" />
</request>
<response type='Ens.StringResponse' >
<assign property="response" value="callresponse" action="set" languageOverride="" />
</response>
</call>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
