/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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


module org.eclipse.jface.text.templates.TemplateException;
import org.eclipse.jface.text.templates.TemplateVariable;
import org.eclipse.jface.text.templates.TemplateTranslator;
import org.eclipse.jface.text.templates.SimpleTemplateVariableResolver;
import org.eclipse.jface.text.templates.TemplateBuffer;
import org.eclipse.jface.text.templates.TemplateContextType;
import org.eclipse.jface.text.templates.DocumentTemplateContext;
import org.eclipse.jface.text.templates.GlobalTemplateVariables;
import org.eclipse.jface.text.templates.Template;
import org.eclipse.jface.text.templates.TextTemplateMessages;
import org.eclipse.jface.text.templates.TemplateVariableType;
import org.eclipse.jface.text.templates.TemplateContext;
import org.eclipse.jface.text.templates.TemplateVariableResolver;


import java.lang.all;


/**
 * Thrown when a template cannot be validated.
 * <p>
 * Clients may instantiate this class.
 * </p>
 * <p>
 * This class is not intended to be serialized.
 * </p>
 *
 * @since 3.0
 */
public class TemplateException : Exception {

    /**
     * Serial version UID for this class.
     * <p>
     * Note: This class is not intended to be serialized.
     * </p>
     * @since 3.1
     */
    private static const long serialVersionUID= 3906362710416699442L;

    /**
     * Creates a new template exception.
     */
    public this() {
        super(null);
    }

    /**
     * Creates a new template exception.
     *
     * @param message the message describing the problem that arose
     */
    public this(String message) {
        super(message);
    }

    /**
     * Creates a new template exception.
     *
     * @param message the message describing the problem that arose
     * @param cause the original exception
     */
    public this(String message, Exception cause) {
        super(message, cause);
    }

    /**
     * Creates a new template exception.
     *
     * @param cause the original exception
     */
    public this(Exception cause) {
        super(null, cause);
    }
}
