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
module org.eclipse.jface.text.templates.SimpleTemplateVariableResolver;
import org.eclipse.jface.text.templates.TemplateVariable;
import org.eclipse.jface.text.templates.TemplateTranslator;
import org.eclipse.jface.text.templates.TemplateException;
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
import java.util.Set;


/**
 * A simple template variable resolver, which always evaluates to a defined string.
 * <p>
 * Clients may instantiate and extend this class.
 * </p>
 *
 * @since 3.0
 */
public class SimpleTemplateVariableResolver : TemplateVariableResolver {

    /** The string to which this variable evaluates. */
    private String fEvaluationString;

    /*
     * @see TemplateVariableResolver#TemplateVariableResolver(String, String)
     */
    protected this(String type, String description) {
        super(type, description);
    }

    /**
     * Sets the string to which this variable evaluates.
     *
     * @param evaluationString the evaluation string, may be <code>null</code>.
     */
    public final void setEvaluationString(String evaluationString) {
        fEvaluationString= evaluationString;
    }

    /*
     * @see TemplateVariableResolver#evaluate(TemplateContext)
     */
    protected String resolve(TemplateContext context) {
        return fEvaluationString;
    }

    /**
     * Returns always <code>true</code>, since simple variables are normally
     * unambiguous.
     *
     * @param context {@inheritDoc}
     * @return <code>true</code>
     */
    protected bool isUnambiguous(TemplateContext context) {
        return true;
    }
}
