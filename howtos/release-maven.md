Release a new version
=====================

* ensure the correct java version
  * e.g. `sdk use java 8`
* execute `maven-release.sh <branch> <version>`

Configure a maven repo on a fresh system
========================================

* `settings.xml` in `.m2` should be of this form

```xml
<settings>
  <servers>
    <server>
      <id>central</id>
      <username>$accesstoken-name</username>
	  <password>$accesstoken-password</password>
    </server>
  </servers>
  <profiles>
    <profile>
      <id>central</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <gpg.executable>gpg</gpg.executable>
        <gpg.passphrase>$passphrase</gpg.passphrase>
      </properties>
    </profile>
  </profiles>
</settings>
```

Configure an old project (OSSRH) to the new way (CENTRAL)
=========================================================

* `pom.xml` should no longer contain `<distributionManagement>...</distributionManagement>`
* `pom.xml` should not contain in `<plugins>`
`nexus-staging-maven-plugin`
* `pom.xml` should contain in `<plugins>`

```xml
<plugin>
	<groupId>org.sonatype.central</groupId>
	<artifactId>central-publishing-maven-plugin</artifactId>
	<version>0.5.0</version>
	<extensions>true</extensions>
</plugin>
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-gpg-plugin</artifactId>
	<version>3.1.0</version>
	<executions>
		<execution>
			<id>sign-artifacts</id>
			<phase>verify</phase>
			<goals>
				<goal>sign</goal>
			</goals>
		</execution>
	</executions>
</plugin>
```

