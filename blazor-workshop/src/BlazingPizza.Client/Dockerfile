# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["src/BlazingPizza.client.sln", "./"]
COPY ["Directory.Build.props", "./"]
COPY ["src/BlazingPizza.Client/BlazingPizza.Client.csproj", "src/BlazingPizza.Client/"]
COPY ["src/BlazingPizza.Shared/BlazingPizza.Shared.csproj", "src/BlazingPizza.Shared/"]
COPY ["src/BlazingComponents/BlazingComponents.csproj", "src/BlazingComponents/"]

# Restore packages
RUN dotnet restore "src/BlazingPizza.Client/BlazingPizza.Client.csproj"

# Copy everything else including wwwroot
COPY . .

# Build and publish
WORKDIR "/src/src/BlazingPizza.Client"
RUN curl -sL https://sentry.io/get-cli/ | bash
ARG SENTRY_RELEASE
ENV SENTRY_RELEASE=${SENTRY_RELEASE}
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Runtime
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy built app including config
COPY --from=build /app/publish/wwwroot .

# Copy nginx config
COPY ["src/BlazingPizza.Client/nginx.conf", "/etc/nginx/nginx.conf"]

EXPOSE 80
