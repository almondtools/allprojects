* Adjust version by removing the -SNAPSHOT-suffix
* commit version ("release X.X.X") and tag it with version-X.X.X
* push this version (and the tags) to github
* `./gradlew publishToSonatype`
  * inspect nexus sonatype staging repository (gets visible after login to https://oss.sonatype.org) 
  * sources.jar should be there
  * javadoc.jar should be there
  * artifact.jar should be there
* `./gradlew findSonatypeStagingRepository closeSonatypeStagingRepository`
* `./gradlew findSonatypeStagingRepository releaseSonatypeStagingRepository`
* Adjust version by writing the -SNAPSHOT-suffix with new version
* commit version ("snapshot")