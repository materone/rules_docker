# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""A rule for creating a Scala container image.

The signature of scala_image is compatible with scala_binary.
"""

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary")
load("//container:container.bzl", "container_image")
load(
    "//java:image.bzl",
    "DEFAULT_JAVA_BASE",
    _repositories = "repositories",
)

# TODO(mattmoor): Take advantage of layering.
def scala_image(name, base=None, deps=[], layers=[], **kwargs):
  """Builds a container image overlaying the scala_binary.

  Args:
    layers: Augments "deps" with dependencies that should be put into
           their own layers.
    **kwargs: See scala_binary.
  """
  binary_name = name + ".binary"

  if layers:
    print("scala_image does not yet take advantage of the layers attribute.")

  scala_binary(name=binary_name, deps=(deps + layers) or None, **kwargs)

  base = base or DEFAULT_JAVA_BASE

  container_image(
      name=name,
      base=base,
      directory="/",
      files=[":" + binary_name + "_deploy.jar"],
      entrypoint=["/usr/bin/java", "-jar", "/" + binary_name + "_deploy.jar"],
      legacy_run_behavior = False,
      visibility=kwargs.get('visibility', None),
  )

def repositories():
  _repositories()
