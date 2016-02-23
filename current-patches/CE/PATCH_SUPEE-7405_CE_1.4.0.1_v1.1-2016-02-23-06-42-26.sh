#!/bin/bash
# Patch apllying tool template
# v0.1.2
# (c) Copyright 2013. Magento Inc.
#
# DO NOT CHANGE ANY LINE IN THIS FILE.

# 1. Check required system tools
_check_installed_tools() {
    local missed=""

    until [ -z "$1" ]; do
        type -t $1 >/dev/null 2>/dev/null
        if (( $? != 0 )); then
            missed="$missed $1"
        fi
        shift
    done

    echo $missed
}

REQUIRED_UTILS='sed patch'
MISSED_REQUIRED_TOOLS=`_check_installed_tools $REQUIRED_UTILS`
if (( `echo $MISSED_REQUIRED_TOOLS | wc -w` > 0 ));
then
    echo -e "Error! Some required system tools, that are utilized in this sh script, are not installed:\nTool(s) \"$MISSED_REQUIRED_TOOLS\" is(are) missed, please install it(them)."
    exit 1
fi

# 2. Determine bin path for system tools
CAT_BIN=`which cat`
PATCH_BIN=`which patch`
SED_BIN=`which sed`
PWD_BIN=`which pwd`
BASENAME_BIN=`which basename`

BASE_NAME=`$BASENAME_BIN "$0"`

# 3. Help menu
if [ "$1" = "-?" -o "$1" = "-h" -o "$1" = "--help" ]
then
    $CAT_BIN << EOFH
Usage: sh $BASE_NAME [--help] [-R|--revert] [--list]
Apply embedded patch.

-R, --revert    Revert previously applied embedded patch
--list          Show list of applied patches
--help          Show this help message
EOFH
    exit 0
fi

# 4. Get "revert" flag and "list applied patches" flag
REVERT_FLAG=
SHOW_APPLIED_LIST=0
if [ "$1" = "-R" -o "$1" = "--revert" ]
then
    REVERT_FLAG=-R
fi
if [ "$1" = "--list" ]
then
    SHOW_APPLIED_LIST=1
fi

# 5. File pathes
CURRENT_DIR=`$PWD_BIN`/
APP_ETC_DIR=`echo "$CURRENT_DIR""app/etc/"`
APPLIED_PATCHES_LIST_FILE=`echo "$APP_ETC_DIR""applied.patches.list"`

# 6. Show applied patches list if requested
if [ "$SHOW_APPLIED_LIST" -eq 1 ] ; then
    echo -e "Applied/reverted patches list:"
    if [ -e "$APPLIED_PATCHES_LIST_FILE" ]
    then
        if [ ! -r "$APPLIED_PATCHES_LIST_FILE" ]
        then
            echo "ERROR: \"$APPLIED_PATCHES_LIST_FILE\" must be readable so applied patches list can be shown."
            exit 1
        else
            $SED_BIN -n "/SUP-\|SUPEE-/p" $APPLIED_PATCHES_LIST_FILE
        fi
    else
        echo "<empty>"
    fi
    exit 0
fi

# 7. Check applied patches track file and its directory
_check_files() {
    if [ ! -e "$APP_ETC_DIR" ]
    then
        echo "ERROR: \"$APP_ETC_DIR\" must exist for proper tool work."
        exit 1
    fi

    if [ ! -w "$APP_ETC_DIR" ]
    then
        echo "ERROR: \"$APP_ETC_DIR\" must be writeable for proper tool work."
        exit 1
    fi

    if [ -e "$APPLIED_PATCHES_LIST_FILE" ]
    then
        if [ ! -w "$APPLIED_PATCHES_LIST_FILE" ]
        then
            echo "ERROR: \"$APPLIED_PATCHES_LIST_FILE\" must be writeable for proper tool work."
            exit 1
        fi
    fi
}

_check_files

# 8. Apply/revert patch
# Note: there is no need to check files permissions for files to be patched.
# "patch" tool will not modify any file if there is not enough permissions for all files to be modified.
# Get start points for additional information and patch data
SKIP_LINES=$((`$SED_BIN -n "/^__PATCHFILE_FOLLOWS__$/=" "$CURRENT_DIR""$BASE_NAME"` + 1))
ADDITIONAL_INFO_LINE=$(($SKIP_LINES - 3))p

_apply_revert_patch() {
    DRY_RUN_FLAG=
    if [ "$1" = "dry-run" ]
    then
        DRY_RUN_FLAG=" --dry-run"
        echo "Checking if patch can be applied/reverted successfully..."
    fi
    PATCH_APPLY_REVERT_RESULT=`$SED_BIN -e '1,/^__PATCHFILE_FOLLOWS__$/d' "$CURRENT_DIR""$BASE_NAME" | $PATCH_BIN $DRY_RUN_FLAG $REVERT_FLAG -p0`
    PATCH_APPLY_REVERT_STATUS=$?
    if [ $PATCH_APPLY_REVERT_STATUS -eq 1 ] ; then
        echo -e "ERROR: Patch can't be applied/reverted successfully.\n\n$PATCH_APPLY_REVERT_RESULT"
        exit 1
    fi
    if [ $PATCH_APPLY_REVERT_STATUS -eq 2 ] ; then
        echo -e "ERROR: Patch can't be applied/reverted successfully."
        exit 2
    fi
}

REVERTED_PATCH_MARK=
if [ -n "$REVERT_FLAG" ]
then
    REVERTED_PATCH_MARK=" | REVERTED"
fi

_apply_revert_patch dry-run
_apply_revert_patch

# 9. Track patch applying result
echo "Patch was applied/reverted successfully."
ADDITIONAL_INFO=`$SED_BIN -n ""$ADDITIONAL_INFO_LINE"" "$CURRENT_DIR""$BASE_NAME"`
APPLIED_REVERTED_ON_DATE=`date -u +"%F %T UTC"`
APPLIED_REVERTED_PATCH_INFO=`echo -n "$APPLIED_REVERTED_ON_DATE"" | ""$ADDITIONAL_INFO""$REVERTED_PATCH_MARK"`
echo -e "$APPLIED_REVERTED_PATCH_INFO\n$PATCH_APPLY_REVERT_RESULT\n\n" >> "$APPLIED_PATCHES_LIST_FILE"

exit 0


SUPEE-7405 | CE_1.4.0.1 | v1.1 | a2afe6d4dfb37a98e5efb1df78ec5bbcfb1f8a48 | Fri Feb 5 16:59:08 2016 +0200 | 914a59d6d5a3ac981ece5a27ec20080f6f0c7160..a2afe6d4dfb37a98e5efb1df78ec5bbcfb1f8a48

__PATCHFILE_FOLLOWS__
diff --git app/code/core/Mage/Adminhtml/Helper/Sales.php app/code/core/Mage/Adminhtml/Helper/Sales.php
index 804a499..6d43af5 100644
--- app/code/core/Mage/Adminhtml/Helper/Sales.php
+++ app/code/core/Mage/Adminhtml/Helper/Sales.php
@@ -94,7 +94,7 @@ class Mage_Adminhtml_Helper_Sales extends Mage_Core_Helper_Abstract
     public function escapeHtmlWithLinks($data, $allowedTags = null)
     {
         if (!empty($data) && is_array($allowedTags) && in_array('a', $allowedTags)) {
-            $links = [];
+            $links = array();
             $i = 1;
             $regexp = "/<a\s[^>]*href\s*?=\s*?([\"\']??)([^\" >]*?)\\1[^>]*>(.*)<\/a>/siU";
             while (preg_match($regexp, $data, $matches)) {
diff --git app/code/core/Mage/Core/Helper/Abstract.php app/code/core/Mage/Core/Helper/Abstract.php
index d64e9a0..2f68e09 100644
--- app/code/core/Mage/Core/Helper/Abstract.php
+++ app/code/core/Mage/Core/Helper/Abstract.php
@@ -166,12 +166,12 @@ abstract class Mage_Core_Helper_Abstract
      * @param   array $allowedTags
      * @return  mixed
      */
-    public function htmlEscape($data, $allowedTags = null)
+    public function escapeHtml($data, $allowedTags = null)
     {
         if (is_array($data)) {
             $result = array();
             foreach ($data as $item) {
-                $result[] = $this->htmlEscape($item);
+                $result[] = $this->escapeHtml($item);
             }
         } else {
             // process single item
@@ -192,6 +192,19 @@ abstract class Mage_Core_Helper_Abstract
     }
 
     /**
+     * Alias for 'escapeHtml'.
+     *
+     * @deprecated
+     * @param mixed $data
+     * @param array $allowedTags
+     * @return mixed
+     */
+    public function htmlEscape($data, $allowedTags = null)
+    {
+        return $this->escapeHtml($data, $allowedTags);
+    }
+
+    /**
      * Escape html entities in url
      *
      * @param string $data
diff --git app/code/core/Mage/Core/Model/Config.php app/code/core/Mage/Core/Model/Config.php
index b2344691..06e8b75 100644
--- app/code/core/Mage/Core/Model/Config.php
+++ app/code/core/Mage/Core/Model/Config.php
@@ -1480,9 +1480,9 @@ class Mage_Core_Model_Config extends Mage_Core_Model_Config_Base
      * Makes all events to lower-case
      *
      * @param string $area
-     * @param Mage_Core_Model_Config_Base $mergeModel
+     * @param Varien_Simplexml_Config $mergeModel
      */
-    protected function _makeEventsLowerCase($area, Mage_Core_Model_Config_Base $mergeModel)
+    protected function _makeEventsLowerCase($area, Varien_Simplexml_Config $mergeModel)
     {
         $events = $mergeModel->getNode($area . "/" . Mage_Core_Model_App_Area::PART_EVENTS);
         if ($events !== false) {
diff --git app/code/core/Mage/Core/functions.php app/code/core/Mage/Core/functions.php
index 725c39f..a362e81 100644
--- app/code/core/Mage/Core/functions.php
+++ app/code/core/Mage/Core/functions.php
@@ -242,7 +242,11 @@ function mageCoreErrorHandler($errno, $errstr, $errfile, $errline){
 
     $errorMessage .= ": {$errstr}  in {$errfile} on line {$errline}";
 
-    throw new Exception($errorMessage);
+    if (Mage::getIsDeveloperMode()) {
+        throw new Exception($errorMessage);
+    } else {
+        Mage::log($errorMessage, Zend_Log::ERR);
+    }
 }
 
 function mageDebugBacktrace($return=false, $html=true, $showFirst=false)
diff --git app/code/core/Mage/Sales/Model/Quote/Item.php app/code/core/Mage/Sales/Model/Quote/Item.php
index 215a459..4129b14 100644
--- app/code/core/Mage/Sales/Model/Quote/Item.php
+++ app/code/core/Mage/Sales/Model/Quote/Item.php
@@ -371,8 +371,9 @@ class Mage_Sales_Model_Quote_Item extends Mage_Sales_Model_Quote_Item_Abstract
                             $itemOptionValue = $_itemOptionValue;
                             $optionValue = $_optionValue;
                             // looks like it does not break bundle selection qty
-                            unset($itemOptionValue['qty'], $itemOptionValue['uenc']);
-                            unset($optionValue['qty'], $optionValue['uenc']);
+                            foreach (array('qty', 'uenc', 'form_key') as $key) {
+                                unset($itemOptionValue[$key], $optionValue[$key]);
+                            }
                         }
 
                     } catch (Exception $e) {
diff --git lib/Varien/File/Uploader.php lib/Varien/File/Uploader.php
index eb445bd..55dcf6a 100644
--- lib/Varien/File/Uploader.php
+++ lib/Varien/File/Uploader.php
@@ -185,7 +185,7 @@ class Varien_File_Uploader
         $result = move_uploaded_file($this->_file['tmp_name'], $destFile);
 
         if( $result ) {
-            chmod($destFile, 0777);
+            chmod($destFile, 0666);
             if ( $this->_enableFilesDispersion ) {
                 $fileName = str_replace(DIRECTORY_SEPARATOR, '/', self::_addDirSeparator($this->_dispretionPath)) . $fileName;
             }
