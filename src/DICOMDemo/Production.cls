Class DICOMDemo.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="DICOMDemo.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="DICOMDemo.BP.CreateDICOM" Category="" ClassName="DICOMDemo.BP.CreateDICOM" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="DICOMDemo.BO.File" Category="" ClassName="DICOMDemo.BO.File" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="FileStorageDirectory">C:\Temp\Practice\Demo</Setting>
  </Item>
</Production>
}

}
