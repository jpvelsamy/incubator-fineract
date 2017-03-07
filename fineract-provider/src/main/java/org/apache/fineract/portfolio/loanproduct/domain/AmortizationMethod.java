/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.apache.fineract.portfolio.loanproduct.domain;

public enum AmortizationMethod {
	WHITEPACE_INSTALLMENTS(0, "amortizationType.equal.whitepsace"),
    EQUAL_PRINCIPAL(1, "amortizationType.equal.principal"), 
    EQUAL_INSTALLMENTS(2, "amortizationType.equal.installments");

    private final Integer value;
    private final String code;

    private AmortizationMethod(final Integer value, final String code) {
        this.value = value;
        this.code = code;
    }

    public Integer getValue() {
        return this.value;
    }

    public String getCode() {
        return this.code;
    }

    public static AmortizationMethod fromInt(final Integer selectedMethod) {

        if (selectedMethod == null) { return null; }

        AmortizationMethod repaymentMethod = null;
        switch (selectedMethod) {
            case 0:
                repaymentMethod = AmortizationMethod.WHITEPACE_INSTALLMENTS;
            break;
            case 1:
                repaymentMethod = AmortizationMethod.EQUAL_PRINCIPAL;
            break;
            case 2:
                repaymentMethod = AmortizationMethod.EQUAL_INSTALLMENTS;
            break;
            default:
                repaymentMethod = AmortizationMethod.WHITEPACE_INSTALLMENTS;
            break;
        }
        return repaymentMethod;
    }

    public boolean isEqualInstallment() {
        return this.value.equals(AmortizationMethod.EQUAL_INSTALLMENTS.getValue());
    }
    
    public boolean isEqualPrincipal() {
        return this.value.equals(AmortizationMethod.EQUAL_PRINCIPAL.getValue());
    }
    
    public boolean isWhiteSpace(){
    	return this.value.equals(AmortizationMethod.WHITEPACE_INSTALLMENTS.getValue());
    }
}