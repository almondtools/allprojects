Release a new version
=====================

* ensure the correct java version
  * e.g. `sdk use java 17`
* make sure that the git project is correctly configured [prepare-git](prepare-git.md)
* execute `gradle-release.sh <branch> <version> <next-snapshot>`
* sign in into [maven central](https://central.sonatype.com/publishing) and manually publish the version, if not published already


Configure a gradle on a fresh system
====================================

* `settings.xml` in `~/.gradle/gradle.properties` should be of this form

```properties
centralUsername=$accesstoken-name
centralPassword=$accesstoken-password

signing.gnupg.executable=gpg
signing.gnupg.passphrase=$passphrase
signing.gnupg.keyName=$keyname
```

Configure an old project (OSSRH) to the new way (CENTRAL)
=========================================================

* `build.gradle` should look similar to

```

import org.gradle.jvm.toolchain.JavaLanguageVersion

plugins {
    id 'java-library'
    id 'maven-publish'
    id 'signing'
    id("com.github.ben-manes.versions") version "0.52.0"
}

group = '???'
description = '???'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }

    withSourcesJar()
    withJavadocJar()
}

repositories {
    mavenCentral()
    mavenLocal()
}

publishing {
    publications {
        mavenJava(MavenPublication) {
            from components.java

            pom {
                name = '???'
                description = '???'
                url = 'https://???'

                licenses {
                    license {
                        name = '???'
                        url = '???'
                    }
                }

                developers {
                    developer {
                        id = '???'
                        name = '???'
                        email = '???'
                    }
                }

                scm {
                    connection = 'scm:git:https://???'
                    developerConnection = 'scm:git:https://???'
                    url = 'https://???'
                }
            }
        }
    }
}

signing {
    useGpgCmd()
    sign publishing.publications.mavenJava
}


tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
}

tasks.withType(Javadoc) {
    options.encoding = 'UTF-8'
    options.addBooleanOption('Xdoclint:none', true)
}
```

* `gradle.properties` should contain

```
version=???
```

* `settings.gradle` should contain

```
plugins {
  id("com.gradleup.nmcp.settings").version("1.4.4")
}

rootProject.name = '???'


nmcpSettings {
  centralPortal {
	username = settings.providers.gradleProperty("centralUsername").get()
	password = settings.providers.gradleProperty("centralPassword").get()
  }
}
```
