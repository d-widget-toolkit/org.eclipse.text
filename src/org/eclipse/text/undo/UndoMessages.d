/*******************************************************************************
 * Copyright (c) 2006 IBM Corporation and others.
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
module org.eclipse.text.undo.UndoMessages;
import org.eclipse.text.undo.DocumentUndoManagerRegistry;
import org.eclipse.text.undo.DocumentUndoManager;
import org.eclipse.text.undo.DocumentUndoEvent;
import org.eclipse.text.undo.IDocumentUndoManager;
import org.eclipse.text.undo.IDocumentUndoListener;



import java.lang.all;

import java.util.ResourceBundle;
import java.util.MissingResourceException;
import java.text.MessageFormat;

/**
 * Helper class to get NLSed messages.
 *
 * @since 3.2
 */
final class UndoMessages {

//     private static const String BUNDLE_NAME= "org.eclipse.text.undo.UndoMessages"; //$NON-NLS-1$

    private static const ResourceBundle RESOURCE_BUNDLE;//= ResourceBundle.getBundle(BUNDLE_NAME);

    static this() {
        RESOURCE_BUNDLE = ResourceBundle.getBundle(
            getImportData!("org.eclipse.text.undo.UndoMessages.properties"));
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
