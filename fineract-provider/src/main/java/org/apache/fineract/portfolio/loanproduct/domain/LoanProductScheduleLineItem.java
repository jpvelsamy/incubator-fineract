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

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.apache.fineract.infrastructure.core.domain.AbstractPersistableCustom;

/**
 * Schedule meant to capture manually configured installments based on the
 * maximum payment period
 * 
 * @author jpvel
 *
 */
@Entity
@Table(name = "m_product_loan_schedule")
public class LoanProductScheduleLineItem extends AbstractPersistableCustom<Long> {

	 

	public LoanProductScheduleLineItem(String installNum, BigDecimal installAmt,
			BigDecimal installPrincipal, BigDecimal installInterest) {
		super();		
		this.installNum = installNum;
		this.installAmt = installAmt;
		this.installPrincipal = installPrincipal;
		this.installInterest = installInterest;
	}

	public LoanProduct getLoanProduct() {
		return loanProduct;
	}

	public String getInstallNum() {
		return installNum;
	}

	public BigDecimal getInstallAmt() {
		return installAmt;
	}

	public BigDecimal getInstallPrincipal() {
		return installPrincipal;
	}

	public BigDecimal getInstallInterest() {
		return installInterest;
	}

	@ManyToOne
    @JoinColumn(name = "loan_product_id", nullable = false)
    private LoanProduct loanProduct;

	@Column(name = "installment_no", nullable = false, unique = false)
	private String installNum;

	@Column(name = "installment_amount", scale = 2, precision = 5, nullable = false)
    private BigDecimal installAmt;
	
	@Column(name = "installment_principal", scale = 2, precision = 5, nullable = false)
    private BigDecimal installPrincipal;
	
	@Column(name = "installment_interest", scale = 2, precision = 5, nullable = false)
    private BigDecimal installInterest;

	public void setLoanProduct(LoanProduct loanProduct) {
		this.loanProduct = loanProduct;
	}
	
	
}
