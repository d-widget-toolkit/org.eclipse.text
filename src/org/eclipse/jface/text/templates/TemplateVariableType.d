/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
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
module org.eclipse.jface.text.templates.TemplateVariableType;
import org.eclipse.jface.text.templates.TemplateVariable;
import org.eclipse.jface.text.templates.TemplateTranslator;
import org.eclipse.jface.text.templates.SimpleTemplateVariableResolver;
import org.eclipse.jface.text.templates.TemplateException;
import org.eclipse.jface.text.templates.TemplateBuffer;
import org.eclipse.jface.text.templates.TemplateContextType;
import org.eclipse.jface.text.templates.DocumentTemplateContext;
import org.eclipse.jface.text.templates.GlobalTemplateVariables;
import org.eclipse.jface.text.templates.Template;
import org.eclipse.jface.text.templates.TextTemplateMessages;
import org.eclipse.jface.text.templates.TemplateContext;
import org.eclipse.jface.text.templates.TemplateVariableResolver;



import java.lang.all;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.ArrayList;





import org.eclipse.core.runtime.Assert;


/**
 * Value object that represents the type of a template variable. A type is defined by its name and
 * may have parameters.
 *
 * @since 3.3
 * @noinstantiate This class is not intended to be instantiated by clients.
 */
public final class TemplateVariableType {

    /** The name of the type. */
    private const String fName;
    /** The parameter list. */
    private const List fParams;

    this(String name) {
        this(name, new String[0]);
    }

    this(String name, String[] params) {
        Assert.isLegal(name !is null);
        Assert.isLegal(params !is null);
        fName= name;
        fParams= Collections.unmodifiableList(new ArrayList(Arrays.asList(stringcast(params))));
    }

    /**
     * Returns the type name of this variable type.
     *
     * @return the type name of this variable type
     */
    public String getName() {
        return fName;
    }

    /**
     * Returns the unmodifiable and possibly empty list of parameters (element type: {@link String})
     *
     * @return the list of parameters
     */
    public List getParams() {
        return fParams;
    }

    /*
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public override int opEquals(Object obj) {
        if ( cast(TemplateVariableType)obj ) {
            TemplateVariableType other= cast(TemplateVariableType) obj;
            return other.fName.equals(fName) && other.fParams.opEquals(cast(Object)fParams);
        }
        return false;
    }

    /*
     * @see java.lang.Object#hashCode()
     */
    public override hash_t toHash() {
        alias .toHash toHash;
        return fName.toHash() + fParams.toHash();
    }
    /*
     * @see java.lang.Object#toString()
     * @since 3.3
     */
    public override String toString() {
        return fName ~ (cast(Object)fParams).toString();
    }
}
