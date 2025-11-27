# Development

1. csproj file needs the following xml tags
   ```xml
    <ContainerRegistry>harbor.nscubed.lan</ContainerRegistry>
    <ContainerRepository>nscubed/helloworld</ContainerRepository>
   ```
2. Dotnet Publish will create the container and push it to harbor
   ```pwsh
   dotnet publish --os linux --arch x64 /t:PublishContainer /p:ContainerImageTags='"0.0.2;latest"'
   ```
3. in the manifest image tag needs to state
   ```yaml
   image: harbor.nscubed.lan/nscubed/<project>:<tag>
   ```


