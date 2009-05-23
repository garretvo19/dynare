/*
* Copyright (C) 2008-2009 Dynare Team
*
* This file is part of Dynare.
*
* Dynare is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Dynare is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Dynare.  If not, see <http://www.gnu.org/licenses/>.
*/

/* derived from c++kalman_filter library by O. Kamenik */

#ifndef KALMAN_H
#define KALMAN_H

#include "state_init.h"
#include "ssf.h"
#include "ssf_uni.h"
#include "utils.h"

#include <vector> 



class FilterResults{
  protected:
    std::vector<PLUFact*> Finv;
    std::vector<Vector*> v;
    std::vector<GeneralMatrix*> L;
    std::vector<Vector*> a;
    std::vector<GeneralMatrix*> P;
    std::vector<double> loglik;
    int maxt;
  public:
    FilterResults(int num)
      :Finv(num,(PLUFact*)0),v(num,(Vector*)0),L(num,(GeneralMatrix*)0),
      a(num,(Vector*)0),P(num,(GeneralMatrix*)0),loglik(num,0.0),maxt(0)
      {}
    virtual~FilterResults();
    void set(int t,const PLUFact&FFinv,const Vector&vv,
      const GeneralMatrix&LL,const Vector&aa,
      const GeneralMatrix&P,double ll);
    int getMaxT()const
      {return maxt;}
    bool hasFinished()const
      {return maxt==(int)Finv.size();}
    const PLUFact&getFInverse(int t)const;
    const Vector&getV(int t)const;
    const GeneralMatrix&getL(int t)const;
    const Vector&getA(int t)const;
    const GeneralMatrix&getP(int)const;
    double getLogLikelihood()const;
  };

;

class DiffuseFilterResults:public FilterResults{
  protected:
    std::vector<GeneralMatrix*> L_1;
    std::vector<GeneralMatrix*> Pinf;
    std::vector<GeneralMatrix*> F_2;
    std::vector<bool> Finf_reg;
    std::vector<bool> Pinf_zero;
  public:
    DiffuseFilterResults(int num)
      :FilterResults(num),
      L_1(num,(GeneralMatrix*)0),
      Pinf(num,(GeneralMatrix*)0),
      F_2(num,(GeneralMatrix*)0),
      Finf_reg(num,true),
      Pinf_zero(num,true)
      {}
    virtual~DiffuseFilterResults();
    void set(int t,const PLUFact&FFinfinv,const GeneralMatrix&FF_2,
      const Vector&vv,const GeneralMatrix&LL_0,
      const GeneralMatrix&LL_1,const Vector&aa,
      const GeneralMatrix&PPstar,const GeneralMatrix&PPinf,
      double ll);
    void set(int t,const PLUFact&FFstarinv,const Vector&vv,
      const GeneralMatrix&LL_0,const Vector&aa,
      const GeneralMatrix&PPstar,const GeneralMatrix&PPinf,
      double ll);
    int getDiffusePeriods()const;
    bool isFinfRegular(int t)const;
    bool isPinfZero(int t)const;
    const PLUFact&getFinfInverse(int t)const;
    const PLUFact&getFstarInverse(int t)const;
    const GeneralMatrix&getF2(int t)const;
    const GeneralMatrix&getL0(int t)const
      {return getL(t);}
    const GeneralMatrix&getL1(int t)const;
    const GeneralMatrix&getPstar(int t)const
      {return getP(t);}
    const GeneralMatrix&getPinf(int t)const;
  };

;

class SmootherResults{
  protected:
    std::vector<Vector*> alpha;
    std::vector<Vector*> eta;
    std::vector<GeneralMatrix*> V;
    int mint;
  public:
    SmootherResults(int num)
      :alpha(num,(Vector*)0),eta(num,(Vector*)0),
      V(num,(GeneralMatrix*)0),
      mint(num+1){}
    virtual~SmootherResults();
    void set(int t,const Vector&aalpha,const Vector&eeta,
      const GeneralMatrix&VV);
    void import(const SmootherResults&sres,int period);
    void exportAlpha(GeneralMatrix&out)const;
    void exportEta(GeneralMatrix&out)const;
    void exportV(GeneralMatrix&out)const;
  };


;

class KalmanUniTask;
class KalmanTask{
  friend class KalmanUniTask;
  SSForm ssf;
  ConstGeneralMatrix data;
  const StateInit&init;
  public:
    KalmanTask(const GeneralMatrix&d,const GeneralMatrix&Z,
      const GeneralMatrix&H,const GeneralMatrix&T,
      const GeneralMatrix&R,const GeneralMatrix&Q,
      const StateInit&init_state);
    KalmanTask(const GeneralMatrix&d,const TMatrix&Z,
      const TMatrix&H,const TMatrix&T,
      const TMatrix&R,const TMatrix&Q,
      const StateInit&init_state);
    double filter(int&per,int&d)const;
    double filter_and_smooth(SmootherResults&sres,int&per,int&d)const;
  protected:
    void filterNonDiffuse(const Vector&a,const GeneralMatrix&Pstar,
      int first,FilterResults&fres)const;
    void filterDiffuse(const Vector&a,const GeneralMatrix&Pstar,
      const GeneralMatrix&Pinf,int first,
      DiffuseFilterResults&fres)const;
    void smootherNonDiffuse(const FilterResults&fres,SmootherResults&sres)const;
    void smootherDiffuse(const DiffuseFilterResults&fres,SmootherResults&sres)const;
    void smootherNonDiffuseStep(int t,const FilterResults&fres,
      Vector&rt,GeneralMatrix&Nt,
      Vector&alphat,GeneralMatrix&Vt,
      Vector&etat)const;
    static double calcStepLogLik(const PLUFact&Finv,const Vector&v);
  };


;

;


class FilterUniResults{
  protected:
    std::vector<double> F;
    std::vector<double> v;
    std::vector<GeneralMatrix*> L;
    std::vector<Vector*> a;
    std::vector<GeneralMatrix*> P;
    std::vector<double> loglik;
    int maxt;
  public:
    FilterUniResults(int num)
      :F(num,0.0),v(num,0.0),L(num,(GeneralMatrix*)0),
      a(num,(Vector*)0),P(num,(GeneralMatrix*)0),loglik(num,0.0),maxt(0)
      {}
    virtual~FilterUniResults();
    void set(int t,double F,double vv,
      const GeneralMatrix&LL,const Vector&aa,
      const GeneralMatrix&P,double ll);
    int getMaxT()const
      {return maxt;}
    bool hasFinished()const
      {return maxt==(int)F.size();}
    double getF(int t)const;
    double getV(int t)const;
    const GeneralMatrix&getL(int t)const;
    const Vector&getA(int t)const;
    const GeneralMatrix&getP(int)const;
    double getLogLikelihood()const;
  };

;

class DiffuseFilterUniResults:public FilterUniResults{
  protected:
    std::vector<GeneralMatrix*> L_1;
    std::vector<GeneralMatrix*> Pinf;
    std::vector<double> F_2;
    std::vector<bool> Finf_reg;
    std::vector<bool> Pinf_zero;
  public:
    DiffuseFilterUniResults(int num)
      :FilterUniResults(num),
      L_1(num,(GeneralMatrix*)0),
      Pinf(num,(GeneralMatrix*)0),
      F_2(num,0.0),
      Finf_reg(num,true),
      Pinf_zero(num,true)
      {}
    virtual~DiffuseFilterUniResults();
    void set(int t,double FFinf,double FF_2,
      double vv,const GeneralMatrix&LL_0,
      const GeneralMatrix&LL_1,const Vector&aa,
      const GeneralMatrix&PPstar,const GeneralMatrix&PPinf,
      double ll);
    void set(int t,double FFstar,double vv,
      const GeneralMatrix&LL_0,const Vector&aa,
      const GeneralMatrix&PPstar,const GeneralMatrix&PPinf,
      double ll);
    int getDiffusePeriods()const;
    bool isFinfRegular(int t)const;
    bool isPinfZero(int t)const;
    double getFinf(int t)const;
    double getFstar(int t)const;
    double getF2(int t)const;
    const GeneralMatrix&getL0(int t)const
      {return getL(t);}
    const GeneralMatrix&getL1(int t)const;
    const GeneralMatrix&getPstar(int t)const
      {return getP(t);}
    const GeneralMatrix&getPinf(int t)const;
  };

;

class KalmanUniTask{
  private:
    MesEquation me;
  protected:
    SSFormUni ssf;
    ConstGeneralMatrix data;
    const StateInit&init;
  public:
    KalmanUniTask(const KalmanTask&kt);
    double filter(int&per,int&d)const;
    double filter_and_smooth(SmootherResults&sres,int&per,int&d)const;
  protected:
    void filterNonDiffuse(const Vector&a,const GeneralMatrix&Pstar,
      int first,FilterUniResults&fres)const;
    void filterDiffuse(const Vector&a,const GeneralMatrix&Pstar,
      const GeneralMatrix&Pinf,int first,
      DiffuseFilterUniResults&fres)const;
    void smootherNonDiffuse(const FilterUniResults&fres,SmootherResults&sres)const;
    void smootherDiffuse(const DiffuseFilterUniResults&fres,SmootherResults&sres)const;
    void smootherNonDiffuseStep(int t,const FilterUniResults&fres,
      Vector&rt,GeneralMatrix&Nt,
      Vector&alphat,GeneralMatrix&Vt,
      Vector&etat)const;
    static double calcStepLogLik(double F,double v);
  };



;

#endif

