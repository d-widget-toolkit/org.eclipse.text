/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.jface.text.TextMessages;

import java.lang.all;

import java.util.ResourceBundle;
import java.util.MissingResourceException;
import java.text.MessageFormat;


/**
 * Helper class to get NLSed messages.
 *
 * @since 3.4
 */
class TextMessages {
//     private static const String BUNDLE_NAME= "org.eclipse.jface.text.TextMessages"; //$NON-NLS-1$

    private static ResourceBundle RESOURCE_BUNDLE_;//= ResourceBundle.getBundle(BUNDLE_NAME);
    private static ResourceBundle RESOURCE_BUNDLE(){
        if( RESOURCE_BUNDLE_ is null ){
            synchronized(TextMessages.classinfo ){
                if( RESOURCE_BUNDLE_ is null ){
                    RESOURCE_BUNDLE_ = ResourceBundle.getBundle(
                        getImportData!("org.eclipse.jface.text.TextMessages.properties"));
                }
            }
        }
        return RESOURCE_BUNDLE_;
    }

    private this() {
    }

    public static String getString(String key) {
        try {
            return RESOURCE_BUNDLE.getString(key);
        } catch (MissingResourceException e) {
            return '!' ~ key ~ '!';
        }
    }

    public static String getFormattedString(String key, Object[] args...) {
        return MessageFormat.format(getString(key), args);
    }

}
