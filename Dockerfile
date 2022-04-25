ARG QUIC=noquic

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base-noquic
WORKDIR /app
EXPOSE 443

FROM base-noquic AS base-quic
# This is a fixed version of the instructions at
# https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel/http3?view=aspnetcore-6.0#linux.
RUN if [ "$QUIC" = "quic" ]; then apt-get update \
    && apt-get install -y curl gnupg2 \
    && (curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmour > /etc/apt/trusted.gpg.d/microsoft.gpg) \
    && (echo 'deb https://packages.microsoft.com/debian/11/prod bullseye main' > /etc/apt/sources.list.d/microsoft.list) \
    && apt-get update \
    && apt-get install -y libmsquic=1.9* \
    && rm -rf /var/lib/apt/lists/* \
    ; fi

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Morphologue.RequestSimultaneityExample.csproj", "./"]
RUN dotnet restore "Morphologue.RequestSimultaneityExample.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "Morphologue.RequestSimultaneityExample.csproj" --no-restore -c Release

FROM build AS publish
RUN dotnet publish "Morphologue.RequestSimultaneityExample.csproj" --no-build -c Release -o /app/publish

FROM base-${QUIC} AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Morphologue.RequestSimultaneityExample.dll"]
