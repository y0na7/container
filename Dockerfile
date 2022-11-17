FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5069

ENV ASPNETCORE_URLS=http://+:5069

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["ibasemployeeservice.csproj", "./"]
RUN dotnet restore "ibasemployeeservice.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "ibasemployeeservice.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ibasemployeeservice.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ibasemployeeservice.dll"]
