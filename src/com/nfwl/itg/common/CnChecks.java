package com.nfwl.itg.common;

import java.io.Serializable;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.validator.Field;
import org.apache.commons.validator.GenericValidator;
import org.apache.commons.validator.Validator;
import org.apache.commons.validator.ValidatorAction;
import org.apache.commons.validator.util.ValidatorUtils;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.validator.Resources;

/**
 * 
 * @Project：cnbaibao   
 * @Type：   CnChecks 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-11-3 下午02:50:56
 * @Comment
 * 
 */

public class CnChecks implements Serializable{

	
	 /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	
	public static boolean validateCnMaxLength(Object bean,
                ValidatorAction va, Field field,
                ActionMessages errors,
                Validator validator,
                HttpServletRequest request) {
		 String value = null;
	        if (isString(bean)) {
	            value = (String) bean;
	        } else {
	            value = ValidatorUtils.getValueAsString(bean, field.getProperty());
	        }

	        if (value != null) {
	            try {
	                int max = Integer.parseInt(field.getVarValue("cnmaxlength"));

	                if (value.getBytes().length>max) {
	                    errors.add(field.getKey(), Resources.getActionMessage(validator, request, va, field));

	                    return false;
	                }
	            } catch (Exception e) {
	                errors.add(field.getKey(), Resources.getActionMessage(validator, request, va, field));
	                return false;
	            }
	        }

	        return true;
	 }
	 
	public static boolean validateCnMinLength(Object bean,
            ValidatorAction va, Field field,
            ActionMessages errors,
            Validator validator,
            HttpServletRequest request) {
		

		 String value = null;
	        if (isString(bean)) {
	            value = (String) bean;
	        } else {
	            value = ValidatorUtils.getValueAsString(bean, field.getProperty());
	        }

	        if (!GenericValidator.isBlankOrNull(value)) {
	            try {
	                int min = Integer.parseInt(field.getVarValue("cnminlength"));

	                if (value.getBytes().length<min) {
	                    errors.add(field.getKey(), Resources.getActionMessage(validator, request, va, field));

	                    return false;
	                }
	            } catch (Exception e) {
	                errors.add(field.getKey(), Resources.getActionMessage(validator, request, va, field));
	                return false;
	            }
	        }

	        return true;
	        
	 }
	/**
	 * Return <code>true</code> if the specified object is a String or a
	 * <code>null</code> value.
	 *
	 * @param o Object to be tested
	 * @return The string value
	 */
	protected static boolean isString(Object o) {
	    return (o == null) ? true : String.class.isInstance(o);
	}
}

