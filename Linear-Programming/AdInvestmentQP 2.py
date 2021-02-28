from gurobipy import *
import math
import numpy as np

# We can adjust the weight here and test Alpha and Beta
Alpha = {'16-24':1,
         '25-34':1,
         '35-44':1,
         '45-54':1,
         '55-64':1}

beta = {'Google':1,
        'Youtube':1,
        'Facebook':1,
        'Instagram':1}

#our utility table
Invest, Utilities = multidict({
  ('Google','16-24'): 29,
  ('Google','25-34'):  31,
  ('Google','35-44'):  30,
  ('Google','45-54'):   13,
  ('Google','55-64'): 7,
  ('Youtube','16-24'): 31,
  ('Youtube','25-34'):  30,
  ('Youtube','35-44'):      20,
  ('Youtube','45-54'):   13,
  ('Youtube','55-64'): 7,
  ('Facebook','16-24'): 25,
  ('Facebook','25-34'):  29,
  ('Facebook','35-44'):      22,
  ('Facebook','45-54'):   15,
  ('Facebook','55-64'):  9,
  ('Instagram','16-24'): 37,
  ('Instagram','25-34'):  34,
  ('Instagram','35-44'):      18,
  ('Instagram','45-54'):   8,
  ('Instagram','55-64'): 3})
    
Age = ['16-24','25-34','35-44','45-54','55-64']
Media = ['Google','Youtube','Facebook','Instagram']




#initializing model
m = Model("media")

#adding our variables and lower bound 0.01, we can change 0.01 to 0 if we dont want this constraint
invest = m.addVars(Invest,lb=0.01,ub=1. ,name="invest")

#our first quadratic risk penalty factor
quad1 = quicksum((quicksum((invest[media,age]-0.2)*(invest[media,age]-0.2)*Alpha[age] for media in Media) for age in Age))

#our second quadratic risk penalty factor
quad2 = quicksum((quicksum((invest[media,age]-0.25)*(invest[media,age]-0.25)*Alpha[age] for age in Age) for media in Media))

#our utility function
m.setObjective(invest.prod(Utilities) - quad1 - quad2  , GRB.MAXIMIZE)

#our constraints
m.addConstr(invest.sum('*')==1)

#the following two constraints can be commented out for testing without constraints
m.addConstr(quicksum(invest[media,'16-24'] for media in Media) + quicksum(invest[media,'25-34'] for media in Media) >=0.5)

m.addConstr(quicksum(invest[media,'16-24'] for media in Media) + quicksum(invest[media,'25-34'] for media in Media) <=0.7)


m.optimize()


#printing our solution
def printSolution():
    if m.status == GRB.Status.OPTIMAL:
        print('\nUtility: %g' % m.objVal)
        print('\nInvest:')
        buyx = m.getAttr('x', invest)
        for f in Utilities:
            print('%s : %g' % (f, buyx[f]))

    else:
        print('No solution')
        
printSolution()
