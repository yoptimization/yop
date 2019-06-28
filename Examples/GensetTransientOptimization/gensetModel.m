function [dX, y] = gensetModel(time, state, control)
% MVEM2 - a diesel-electric powertrain model, with the engine modeled using
% typical engine efficiency characteristic as described in:
% "MODELLING FOR OPTIMAL CONTROL: A VALIDATED DIESEL-ELECTRIC POWERTRAIN MODEL"
% Martin Sivertsson and Lars Erisson
% Contact: marsi@isy.liu.se
%
%The  model has the states: x=[w_ice;p_im;p_em;w_tc]
% controls u=[u_f;u_wg;P_gen].
%MVEM2 takes x and u and param(the model parameters) and returns the
%state derivatives: dx=[dwice;dpim;dpem;dwtc] and some additional variables
%in the struct c.
%
%-----------------------------------------------------------------------------
%     Copyright 2014, Martin Sivertsson, Lars Eriksson
%
%     This package is free software: you can redistribute it and/or modify
%     it under the terms of the GNU Lesser General Public License as
%     published by the Free Software Foundation, version 3 of the License.
%
%     This package is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%     GNU Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% -----------------------------------------------------------------------------
%
%     Modified 2019, Viktor Leek
%
% -----------------------------------------------------------------------------
w_ice = state(1);
p_im = state(2);
p_em = state(3);
w_tc = state(4);
E_gen = state(5);

u_f = control(1);
u_wg = control(2);
P_gen = control(3);

param = gensetParameters;

%% Compressor
% Massflow
Pi_c = p_im / param.p_c_b;

w_tc_corr = w_tc / sqrt(param.T_c_b / param.T_amb);

w_tc_corr_norm = w_tc_corr / 15000;

Pi_c_max=( ...
           (w_tc_corr*param.R_c)^2 * param.Psi_max/(2*param.cp_a.*param.T_c_b) + 1 ...
         )^( param.gamma_a / (param.gamma_a-1) );

dot_m_c_corr_max = param.dot_m_c_corr_max(1)*(w_tc_corr_norm)^2 + ...
                   param.dot_m_c_corr_max(2)*(w_tc_corr_norm) + ...
                   param.dot_m_c_corr_max(3);

dot_m_c_corr = dot_m_c_corr_max * sqrt( 1 - (Pi_c / Pi_c_max).^2 );

dot_m_c = dot_m_c_corr * (param.p_c_b / param.p_amb) / ...
                     sqrt(param.T_c_b /param.T_amb);

% Power
Phi = dot_m_c * param.R_a * param.T_c_b / ...
     (w_tc * 8 * param.R_c^3  * param.p_c_b);

dPhi = Phi - param.Phi_opt;

dN = w_tc_corr_norm - param.w_tc_corr_opt;

eta_c = param.eta_c_max - ...
    ( param.Q(1) * dPhi.^2 + 2*dPhi.*dN* param.Q(3) + ...
      param.Q(2) * dN.^2 );

P_c = dot_m_c * param.cp_a * param.T_c_b * ...
     ( Pi_c^( (param.gamma_a - 1)/param.gamma_a) - 1)/eta_c;

%% Cylinder
% Airflow
eta_vol = param.c_eta_vol(1) * sqrt(p_im) + ....
          param.c_eta_vol(2) * sqrt(w_ice) + ...
          param.c_eta_vol(3);

dot_m_ci = eta_vol * p_im * w_ice * param.V_D / ...
          ( 4*pi * param.R_a * param.T_im);

% Fuelflow
dot_m_f = u_f * w_ice * param.n_cyl*(10^-6) / ...
         ( 4*pi );

phi = (param.AFs * dot_m_f) / dot_m_ci;

% Torque
a = (  param.eta_ig_isl(2) - param.eta_ig_isl(1) ) / ...
    ( -param.eta_ig_isl(3)^2 );

b = -2 * a * param.eta_ig_isl(3);

eta_factor = a*( u_f / w_ice )^2 + b*u_f/w_ice + param.eta_ig_isl(1);

eta_ig = eta_factor * (1 - 1/( param.r_c^(param.gamma_cyl-1) ));

W_pump = param.V_D * (p_em - p_im);

W_ig = param.n_cyl * param.Hlhv * eta_ig * u_f * 10^-6;

W_fric = param.V_D * 10^5 * ...
    ( param.c_fr(1)*(w_ice).^2 + ...
      param.c_fr(2)*(w_ice) + ...
      param.c_fr(3) );

M_ice = ( W_ig - W_fric - W_pump) / (4*pi);

P_ice = M_ice * w_ice;

% Maximum fuel injection
u_f_max = 4*pi * 1e6 * dot_m_ci / ...
    ( w_ice * param.AFs * param.lambda_min * param.n_cyl );

%cylinder_TempOut
Pi_e = p_em / p_im;

q_in = dot_m_f * param.Hlhv / (dot_m_f + dot_m_ci);

T_eo = param.eta_sc * (Pi_e^( 1 - 1/param.gamma_a )) * ...
      (param.r_c.^(1-param.gamma_a)) * ...
      ( q_in / param.cp_a+param.T_im * param.r_c^(param.gamma_a-1) );

T_em = param.T_amb_r + (T_eo-param.T_amb_r) * ...
    exp( -param.h_tot*param.V_tot / ( (dot_m_f+dot_m_ci)*param.cp_e) );


%% turbine
%Massflow
Pi_t = param.p_es / p_em;

Psi_t = param.c_t(1) * sqrt( 1 - Pi_t^param.c_t(2) );

dot_m_t=p_em.*Psi_t*param.A_t_eff./sqrt(T_em*param.R_e);

%Power
BSR = param.R_t * w_tc / ...
      sqrt( 2 * param.cp_e * T_em * (1 - Pi_t^(1 - 1/param.gamma_e)) );

eta_tm = param.eta_tm_max - param.c_m * (BSR - param.BSR_opt)^2;

P_t_eta_tm = dot_m_t * param.cp_e * T_em * eta_tm * ...
            (1 - Pi_t^( (param.gamma_e - 1) / param.gamma_e) );

% wastegate_massflow
Psi_wg = param.c_wg(1) * sqrt(1 - Pi_t^param.c_wg(2));

dot_m_wg = p_em * Psi_wg * param.A_wg_eff * u_wg/sqrt(T_em * param.R_e);

%% Generator
a1 = param.gen2(1)*w_ice^2 + param.gen2(2)*w_ice + param.gen2(3);
a2 = param.gen2(4)*w_ice^2 + param.gen2(5)*w_ice + param.gen2(6);

f1 = a1*P_gen + param.gen2(7);
f2 = a2*P_gen + param.gen2(7);

g1 = ( 1 + tanh( 0.005 * P_gen ) )/2;

P_mech = f2 + g1*( f1 - f2 );

%% Dynamic equations
dwice = (P_ice - P_mech) / w_ice / param.J_genset;

dpim = param.R_a * param.T_im * ( dot_m_c - dot_m_ci ) / param.V_is;

dpem = param.R_e * T_em * (dot_m_ci + dot_m_f - dot_m_t - dot_m_wg) / param.V_em;

dwtc = (P_t_eta_tm - P_c) / (w_tc * param.J_tc);

dE_gen = P_gen;

dX = [dwice; dpim; dpem; dwtc; dE_gen];

%% Signals
y.compressor.speed = w_tc;
y.compressor.pressureRatio = Pi_c;
y.compressor.efficiency = eta_c;
y.compressor.power = P_c;
y.compressor.surgeline = param.c_mc_surge(1) * dot_m_c_corr + param.c_mc_surge(2);

y.intake.pressure = p_im;
y.intake.temperature = param.T_im;

y.cylinder.volumetricEfficiency = eta_vol;
y.cylinder.airMassflow = dot_m_ci;
y.cylinder.fuelInjection = u_f;
y.cylinder.fuelMassflow = dot_m_f;
y.cylinder.fuelToAirRatio = phi;
y.cylinder.indicatedEfficiency = eta_ig;
y.cylinder.indicatedTorque = W_ig/(4*pi);
y.cylinder.pumpingTorque = W_pump/(4*pi);
y.cylinder.frictionTorque = W_fric/(4*pi);
y.cylinder.temperatureOut = T_eo;
y.cylinder.fuelLimiter = u_f_max;
y.cylinder.lambdaMin = 1.2;

y.engine.speed = w_ice;
y.engine.efficiency = if_else(u_f <= 0, 0, P_ice/(dot_m_f*param.Hlhv));
y.engine.torque = M_ice;
y.engine.power = P_ice;
y.engine.powerLimit = [(param.cPice(1)*w_ice^2 + param.cPice(2)*w_ice + param.cPice(3)); ....
                       (param.cPice(4)*w_ice^2 + param.cPice(5)*w_ice + param.cPice(6))];

y.exhaust.pressure = p_em;
y.exhaust.temperature = T_em;

y.turbine.speed = w_tc;
y.turbine.pressureRatio = Pi_t;
y.turbine.massflow = dot_m_t;
y.turbine.BSR = BSR;
y.turbine.BSRMax = param.BSR_max;
y.turbine.BSRMin = param.BSR_min;
y.turbine.efficiency = eta_tm;
y.turbine.power = P_t_eta_tm;

y.wastegate.control = u_wg;
y.wastegate.massflow = dot_m_wg;

y.turbocharger.speed = w_tc;

y.generator.power = P_gen;
y.generator.energy = E_gen;


end