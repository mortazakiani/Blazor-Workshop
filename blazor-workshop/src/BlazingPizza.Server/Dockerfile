# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["src/BlazingPizza.server.sln", "./"]
COPY ["Directory.Build.props", "./"]
COPY ["src/BlazingPizza.Server/BlazingPizza.Server.csproj", "src/BlazingPizza.Server/"]
COPY ["src/BlazingPizza.Shared/BlazingPizza.Shared.csproj", "src/BlazingPizza.Shared/"]
COPY ["src/BlazingComponents/BlazingComponents.csproj", "src/BlazingComponents/"]
COPY ["src/BlazingPizza.Client/BlazingPizza.Client.csproj", "src/BlazingPizza.Client/"]
COPY ["src/BlazingPizza.ComponentsLibrary/BlazingPizza.ComponentsLibrary.csproj", "src/BlazingPizza.ComponentsLibrary/"]

# Restore packages
RUN dotnet restore "src/BlazingPizza.Server/BlazingPizza.Server.csproj"

# Copy everything else
COPY . .

# Generate development certificate inside container
RUN dotnet dev-certs https -ep /https/aspnetapp.pfx -p "SecurePassword123" && \
    dotnet dev-certs https --trust

# Build and publish
WORKDIR "/src/src/BlazingPizza.Server"
RUN dotnet publish -c Release -o /app/publish \
    /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
RUN curl -sL https://sentry.io/get-cli/ | bash
WORKDIR /app
COPY --from=build /app/publish .
COPY --from=build /https /https
ARG SENTRY_RELEASE
ENV SENTRY_RELEASE=${SENTRY_RELEASE}

# Set up HTTPS in container
ENV ASPNETCORE_Kestrel__Certificates__Default__Password="SecurePassword123"
ENV ASPNETCORE_Kestrel__Certificates__Default__Path="/https/aspnetapp.pfx"
ENV ASPNETCORE_URLS="https://+;http://+"

# Install SQLite dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Create data directory
RUN mkdir -p /app/Data

ENTRYPOINT ["dotnet", "BlazingPizza.Server.dll"]
