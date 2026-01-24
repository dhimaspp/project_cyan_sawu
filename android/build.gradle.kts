allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Workaround for legacy flutter packages not defining namespace
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            try {
                val android = project.extensions.getByName("android")
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val newNamespace = "com.legacy.${project.name.replace("-", "_")}"
                    setNamespace.invoke(android, newNamespace)
                    println("Added namespace $newNamespace to project ${project.name}")
                }
            } catch (e: Exception) {
                // Ignore, namespace method might not exist on old AGP or other errors
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
