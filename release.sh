echo "version = $1"

# Get version number from version tag
JAR_VERSION=$(echo $1 | cut -d'v' -f2)
echo "jar version = $JAR_VERSION"

rm -rf release
mkdir release
./mvnw clean package -Drevision=$JAR_VERSION -DskipTests
# Copy the jar file to the release directory
cp target/service-b-$JAR_VERSION.jar release/service-b-$JAR_VERSION.jar
