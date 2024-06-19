{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  pythonAtLeast,
  stdenv,

  # build-system
  setuptools,

  # propagates (optional, but unspecified)
  # https://github.com/joblib/joblib#dependencies
  lz4,
  psutil,

  # tests
  pytestCheckHook,
  threadpoolctl,
}:

buildPythonPackage rec {
  pname = "joblib";
  version = "1.4.2";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-I4LFgWsmNvvSCgng9Ona1HNnZf37fcpYKUO5wTZrPw4=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    lz4
    psutil
  ];

  nativeCheckInputs = [
    pytestCheckHook
    threadpoolctl
  ];

  pytestFlagsArray = [ "joblib/test" ];

  disabledTests =
    [
      "test_disk_used" # test_disk_used is broken: https://github.com/joblib/joblib/issues/57
      "test_parallel_call_cached_function_defined_in_jupyter" # jupyter not available during tests
      "test_nested_parallel_warnings" # tests is flaky under load
    ]
    ++ lib.optionals stdenv.isDarwin [
      "test_dispatch_multiprocessing" # test_dispatch_multiprocessing is broken only on Darwin.
    ]
    ++ lib.optionals (pythonAtLeast "3.12") [
      # deprecation warnings with python3.12 https://github.com/joblib/joblib/issues/1478
      "test_main_thread_renamed_no_warning"
      "test_background_thread_parallelism"
    ];

  meta = with lib; {
    changelog = "https://github.com/joblib/joblib/releases/tag/${version}";
    description = "Lightweight pipelining: using Python functions as pipeline jobs";
    homepage = "https://joblib.readthedocs.io/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
