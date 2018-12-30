# TensorFlow Metadata Protos for Java using Maven

The
[TensorFlow Metadata Protos](https://github.com/tensorflow/metadata)
is available on Maven Central and JCenter through artifacts uploaded to
[OSS Sonatype](https://oss.sonatype.org/content/repositories/releases/org/tensorflow/) and
[Bintray](https://bintray.com/google/tensorflow/tensorflow) respectively. This
document describes the process of updating the release artifacts. It does _not_
describe how to use the protos.

## Updating the release

The Maven artifacts are created from files built as part of the
TensorFlow release process (which uses `bazel`). A `BUILD` rule builds
the proto jars before calling a shell script `release.sh` (only tested
on linux) which builds and uploads Maven artifacts.

### Pre-requisites

-   An account at [oss.sonatype.org](https://oss.sonatype.org/), that has
    permissions to update artifacts in the `org.tensorflow.metadata` group. If your
    account does not have permissions, then you'll need to ask someone who does
    to [file a ticket](https://issues.sonatype.org/) to add to the permissions
    ([sample ticket](https://issues.sonatype.org/browse/MVNCENTRAL-1637)).
-   An account at [bintray.com](https://bintray.com) that has permissions to
    update the [tensorflow repository](https://bintray.com/google/tensorflow).
    If your account does not have permissions, then you'll need to ask one of
    the [organization administrators](https://bintray.com/google) to give you
    permissions to update the `tensorflow` repository. Please keep the
    [repository option](https://bintray.com/google/tensorflow/edit?tab=general)
    to *"GPG sign uploaded files using Bintray's public/private key pair"*
    **unchecked**, otherwise it will conflict with locally signed artifacts.
-   A GPG signing key, required
    [to sign the release artifacts](http://central.sonatype.org/pages/apache-maven.html#gpg-signed-components).

### Deploying to Sonatype and Bintray

1.  Create a file with your OSSRH credentials and
    [Bintray API key](https://bintray.com/docs/usermanual/interacting/interacting_interacting.html#anchorAPIKEY)
    (or perhaps you use `mvn` and have it in `~/.m2/settings.xml`):

    ```sh
    SONATYPE_USERNAME="your_sonatype.org_username_here"
    SONATYPE_PASSWORD="your_sonatype.org_password_here"
    BINTRAY_USERNAME="your_bintray_username_here"
    BINTRAY_API_KEY="your_bintray_api_key_here"
    GPG_PASSPHRASE="your_gpg_passphrase_here"
    cat >/tmp/settings.xml <<EOF
    <settings>
      <servers>
        <server>
          <id>ossrh</id>
          <username>${SONATYPE_USERNAME}</username>
          <password>${SONATYPE_PASSWORD}</password>
        </server>
        <server>
          <id>bintray</id>
          <username>${BINTRAY_USERNAME}</username>
          <password>${BINTRAY_API_KEY}</password>
        </server>
      </servers>
      <properties>
        <gpg.executable>gpg2</gpg.executable>
        <gpg.passphrase>${GPG_PASSPHRASE}</gpg.passphrase>
      </properties>
    </settings>
    EOF
    ```

2.  Ensure you have a clean repository with no unsubmitted changes, and
    run the `bazel` command to release artifacts to the bintray or the
    OSSRH repositories:

    ```sh
    $ DEPLOY_BINTRAY=true bazel run tensorflow_metadata/java/maven:release -- 0.9.0
    ```

    Note that you must provide a target version number to the
    command. The previous command will release artifacts just to the
    bintray repository. Setting the environment variable
    `DEPLOY_OSSRH` will release to the Sonatype repository as well.

3.  If the script succeeds then artifacts should have been uploaded to
    the private staging repository in Sonatype, and as unpublished artifacts in
    Bintray. After verifying the release, you should finalize or abort the
    release on both sites.

4.  If you released to Sonatype, Visit
    https://oss.sonatype.org/#stagingRepositories, find the
    `org.tensorflow.metadata` release and click on either `Release` to finalize
    the release, or `Drop` to abort.

5.  Visit https://bintray.com/google/tensorflow-metadata, and select the
    version you just uploaded. Notice there's a message about unpublished
    artifacts. Click on either `Publish` to finalize the release, or `Discard`
    to abort.

6.  Some things of note:
    - For details, look at the [Sonatype guide](http://central.sonatype.org/pages/releasing-the-deployment.html).
    - Syncing with [Maven Central](http://repo1.maven.org/maven2/org/tensorflow/)
      can take 10 minutes to 2 hours (as per the [OSSRH
      guide](http://central.sonatype.org/pages/ossrh-guide.html#releasing-to-central)).
    - For Bintray details, refer to their guide on
      [managing uploaded content](https://bintray.com/docs/usermanual/uploads/uploads_managinguploadedcontent.html#_publishing).

## References

-   [Sonatype guide](http://central.sonatype.org/pages/ossrh-guide.html) for
    hosting releases.
-   [Ticket that created the `org/tensorflow` configuration](https://issues.sonatype.org/browse/OSSRH-28072) on OSSRH.
-   The [Bintray User Manual](https://bintray.com/docs/usermanual/index.html)
