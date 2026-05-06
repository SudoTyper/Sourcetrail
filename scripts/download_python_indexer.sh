# Call from CMakeLists.txtz like: 'download_python_indexer.sh ${CMAKE_BINARY_DIR}
SOURCETRAIL_PYTHON_INDEXER_VERSION="v1_db25_p6"

# Determine current platform
PLATFORM='unknown'
if [ "$(uname)" == "Darwin" ]; then
	PLATFORM='osx'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	PLATFORM='linux'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
	PLATFORM='windows'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
	PLATFORM='windows'
elif [ "$OSTYPE" == "msys" ]; then
	PLATFORM='windows'
fi

PACKAGE_NAME="SourcetrailPythonIndexer_${SOURCETRAIL_PYTHON_INDEXER_VERSION}-${PLATFORM}"
PACKAGE_FILE_NAME="${PACKAGE_NAME}.zip"
PACKAGE_URL="https://github.com/CoatiSoftware/SourcetrailPythonIndexer/releases/download/${SOURCETRAIL_PYTHON_INDEXER_VERSION}/${PACKAGE_FILE_NAME}"
TEMP_PATH="$1/temp"
TARGET_PATH="$1/app/data/python"


ABORT="\033[31mAbort:\033[00m"
SUCCESS="\033[32mSuccess:\033[00m"
INFO="\033[33mInfo:\033[00m"

if [ $PLATFORM == "windows" ]; then
	SCRIPT=`realpath $0`
	if [ "$SCRIPT" == "" ]; then

		ORIGINAL_PATH_TO_SCRIPT="${0}"
		CLEANED_PATH_TO_SCRIPT="${ORIGINAL_PATH_TO_SCRIPT//\\//}"
		SCRIPT_DIR=${CLEANED_PATH_TO_SCRIPT%/*}
	else
		ORIGINAL_PATH_TO_SCRIPT=`dirname $SCRIPT`
		SCRIPT_DIR="${ORIGINAL_PATH_TO_SCRIPT//\\//}"
	fi
else
	SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi

echo "This script is running in: $SCRIPT_DIR"


# Enter main directory
cd $SCRIPT_DIR/
cd ..

BINARY_PATH="$TARGET_PATH/SourcetrailPythonIndexer"
if [ $PLATFORM == "windows" ]; then
	BINARY_PATH="${BINARY_PATH}.exe"
fi

if [ -e "${BINARY_PATH}" ]; then
    echo -e $INFO "SourcetrailPythonIndexer already exists, checking version..."

	INSTALLED_VERSION="$(${BINARY_PATH} --version)"
	INSTALLED_VERSION=${INSTALLED_VERSION#* }
	INSTALLED_VERSION="${INSTALLED_VERSION//./$'_'}"

	if [ "$INSTALLED_VERSION" == "$SOURCETRAIL_PYTHON_INDEXER_VERSION" ]; then
		echo -e $INFO "Nothing to update. Target version of SourcetrailPythonIndexer is already installed."
		exit
	fi
fi

mkdir -p $TEMP_PATH

echo -e $INFO "starting to download $PACKAGE_FILE_NAME"

download_file() {
	URL="$1"
	OUTPUT_PATH="$2"

	if command -v wget >/dev/null 2>&1; then
		wget -O "$OUTPUT_PATH" "$URL"
		if [ $? -eq 0 ] && [ -s "$OUTPUT_PATH" ]; then
			return 0
		fi
		echo -e $INFO "wget failed, trying curl instead."
	fi

	if command -v curl >/dev/null 2>&1; then
		curl -L -f -o "$OUTPUT_PATH" "$URL"
		if [ $? -eq 0 ] && [ -s "$OUTPUT_PATH" ]; then
			return 0
		fi
		echo -e $ABORT "curl failed to download ${PACKAGE_FILE_NAME}."
		exit 1
	else
		echo -e $ABORT "No working downloader available (wget/curl) for ${PACKAGE_FILE_NAME}."
		exit 1
	fi
}

if [ $PLATFORM == "linux" ]; then
	download_file "$PACKAGE_URL" "$TEMP_PATH/$PACKAGE_FILE_NAME"
elif [ $PLATFORM == "osx" ]; then
	download_file "$PACKAGE_URL" "$TEMP_PATH/$PACKAGE_FILE_NAME"
elif [ $PLATFORM == "windows" ]; then
	certutil.exe -urlcache -split -f $PACKAGE_URL $TEMP_PATH/$PACKAGE_FILE_NAME
fi

echo -e $INFO "finished downloading $PACKAGE_FILE_NAME"

if [ ! -s "$TEMP_PATH/$PACKAGE_FILE_NAME" ]; then
	echo -e $ABORT "Download did not produce archive: $TEMP_PATH/$PACKAGE_FILE_NAME"
	exit 1
fi


if [ $PLATFORM == "linux" ]; then
	unzip -d $TEMP_PATH $TEMP_PATH/$PACKAGE_FILE_NAME
elif [ $PLATFORM == "osx" ]; then
	unzip -d $TEMP_PATH $TEMP_PATH/$PACKAGE_FILE_NAME
elif [ $PLATFORM == "windows" ]; then
    7z x $TEMP_PATH/$PACKAGE_FILE_NAME -o$TEMP_PATH
fi


echo -e $INFO "clearing $TARGET_PATH"
rm -rf $TARGET_PATH
mkdir -p $TARGET_PATH
echo -e $INFO "copying downloaded data to $TARGET_PATH"
cp -r $TEMP_PATH/$PACKAGE_NAME/* $TARGET_PATH


echo -e $INFO "clearing temporary data at $TEMP_PATH"
rm -rf $TEMP_PATH
