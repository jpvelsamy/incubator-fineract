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
package org.apache.fineract.portfolio.loanaccount.loanschedule.domain;

import java.math.BigDecimal;
import java.math.MathContext;
import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.fineract.organisation.monetary.domain.Money;
import org.apache.fineract.portfolio.loanaccount.data.LoanTermVariationsData;
import org.apache.fineract.portfolio.loanproduct.domain.LoanProduct;
import org.apache.fineract.portfolio.loanproduct.domain.LoanProductScheduleLineItem;
import org.joda.time.LocalDate;

public class DhuruvaScheduleGenerator extends AbstractLoanScheduleGenerator implements LoanScheduleGenerator {

	@Override
	public PrincipalInterest calculatePrincipalInterestComponentsForPeriod(PaymentPeriodsInOneYearCalculator calculator,
			double interestCalculationGraceOnRepaymentPeriodFraction, Money totalCumulativePrincipal,
			Money totalCumulativeInterest, Money totalInterestDueForLoan, Money cumulatingInterestPaymentDueToGrace,
			Money outstandingBalance, LoanApplicationTerms loanApplicationTerms, int periodNumber, MathContext mc,
			TreeMap<LocalDate, Money> principalVariation, Map<LocalDate, Money> compoundingMap,
			LocalDate periodStartDate, LocalDate periodEndDate, Collection<LoanTermVariationsData> termVariations) {
			System.out.println("Creating a shell payment interest object...");
			LoanProduct product = loanApplicationTerms.getLoanProduct();
			Set<LoanProductScheduleLineItem> scheduleMatrix = product.getScheduleMatrixSet();
			Money principalForThisInstallment = null;
			Money interestForThisInstallment=null;
			Money interestBroughtForwardDueToGrace=Money.of(loanApplicationTerms.getCurrency(), new BigDecimal(0));
			for (LoanProductScheduleLineItem li : scheduleMatrix) {
				if(periodNumber==Integer.parseInt(li.getInstallNum()))
				{
					principalForThisInstallment = Money.of(loanApplicationTerms.getCurrency(), li.getInstallPrincipal());
					interestForThisInstallment = Money.of(loanApplicationTerms.getCurrency(), li.getInstallInterest());
					break;
				}
					
			}			
			
			return new PrincipalInterest(principalForThisInstallment, interestForThisInstallment, interestBroughtForwardDueToGrace);
	}

}
